params = BrpmAuto.params
brpm_rest_client = BrpmRestClient.new

environment = params.request_environment
unless params["server_group"] # can already be populated by the automated tests
  BrpmAuto.log("Getting the server group from the step...")
  params["server_group"] = brpm_rest_client.get_server_group_from_step_id(params["step_id"])
end
server_group = params["server_group"]

target_type = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["target_type"]), "Server group")
target_path = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["target_path"]), "/Applications/#{params["application"]}/#{params["request_environment"]}/#{server_group}")

deploy_job_name = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["deploy_job_name"]), "Deploy #{params["component"]} #{params["component_version"]} in #{environment} - #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}")
deploy_job_group_path = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["deploy_job_group_path"]), "/Applications/#{params["application"]}")

depot_group_path = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["depot_group_path"]), "/Applications/#{params["application"]}/#{params["component"]}")
package_name = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["bl_package_name"]), params["component_version"])

BrpmAuto.log("Logging on to Bladelogic...")
bsa_soap_client = BsaSoapClient.new

BrpmAuto.log("Retrieving the db key of blpackage #{depot_group_path}/#{package_name}...")
package_db_key = bsa_soap_client.blpackage.get_dbkey_by_group_and_name({:parent_group => depot_group_path, :depot_group_path => package_name })

BrpmAuto.log("Retrieving the id of job group #{deploy_job_group_path}...")
deploy_job_group_id = bsa_soap_client.job_group.group_name_to_id({:group_name => deploy_job_group_path })

BrpmAuto.log("Creating Deploy job #{deploy_job_group_path}/#{deploy_job_name}...")
job_db_key = bsa_soap_client.deploy_job.create_deploy_job({:job_name => deploy_job_name, :group_id => deploy_job_group_id, :package_db_key => package_db_key, :server_name => "localhost" })

BrpmAuto.log("Cleaning the servers from the Deploy job...")
job_db_key = bsa_soap_client.job.clear_target_servers({:job_key => job_db_key})

if target_type == "Server group"
  BrpmAuto.log("Adding server group #{target_path} to the Deploy job...")
  job_db_key = bsa_soap_client.job.add_target_group({:job_key => job_db_key, :group_name => target_path})
elsif target_type == "Component group"
  BrpmAuto.log("Adding component group #{target_path} to the Deploy job...")
  job_db_key = bsa_soap_client.job.add_target_component_group({:job_key => job_db_key, :group_name => target_path})
end

BrpmAuto.log("Executing the Deploy job...")
job_run_key = bsa_soap_client.job.execute_job_and_wait({:job_key => job_db_key})
BrpmAuto.log("Job run key is #{job_run_key}.")

BrpmAuto.log("Checking if the job finished successfully...")
had_errors = bsa_soap_client.job_run.get_job_run_had_errors({:job_run_key => job_run_key})

had_errors ? BrpmAuto.log("WARNING: The job had errors!") : BrpmAuto.log("The job had no errors.")
pack_response "job_status", had_errors ? "The job had errors" : "The job ran successfully"

BrpmAuto.log("Retrieving the job run id from the job run key...")
job_run_id = bsa_soap_client.job_run.job_run_key_to_job_run_id({:job_run_key => job_run_key})

results_full_path = "#{params.output_dir}/#{deploy_job_name}_result.csv"

BrpmAuto.log("Retrieving the results from the job run id...")
return_data = bsa_soap_client.utility.export_deploy_script_run({
                                                               :job_group_name => deploy_job_group_path,
                                                               :job_name => deploy_job_name,
                                                               :run_id => job_run_id,
                                                               :export_file_name => results_full_path})
results_content = Base64.decode64(return_data)

File.open(results_full_path, "w") do |f|
  f.puts(results_content)
end

BrpmAuto.log("Parsing the results...")
# As this export contains "embedded" double quotes it is not possible to parse it with the CSV library
log_lines = results_content.split("\n")[6..-1]
log_lines.select! { |log| !log.start_with?("run level log,") }

logs = log_lines.map do |log_line|
  log_items = log_line.split(",",7)

  # 0: server
  # 1: phase
  # 2: attempt
  # 3: date part 1
  # 4: date part 2
  # 5: Info - Warning - Error
  # 6: message

  if log_items.count < 7 # Some lines are broken in two because of end-of-lines appearing in the message field...
    nil
  else
    log_items[6] = log_items[6].tr(",,","")
    log_items[3] = DateTime.parse("#{log_items[3]},#{log_items[4]}")

    log_items
  end
end

logs = logs.compact # removing the possible nils from the array

logs = logs.sort_by { |log| [log[0], log[1], log[3]] }

servers_with_logs = logs.group_by { |log| log[0] }

failed_servers_with_logs = servers_with_logs.select { |key, value| value.select{|log| log[5] == "Error" }.count > 0}

pack_response "results_summary", "#{servers_with_logs.count - failed_servers_with_logs.count}/#{servers_with_logs.count} servers were successful"

table_data = [[' ', 'Server', 'Simulate', 'Stage', 'Commit']]
counter = 0
servers_with_logs.each do |key, logs|
  server = key

  phase_with_logs = logs.group_by { |log| log[1] }

  if phase_with_logs.has_key?("Simulate")
    simulate = phase_with_logs["Simulate"].any? { |log| log[5] == "Error" } ? "Error" : "Succeeded"
  else
    simulate = ""
  end
  if phase_with_logs.has_key?("Stage")
    stage = phase_with_logs["Stage"].any? { |log| log[5] == "Error" } ? "Error" : "Succeeded"
  else
    stage = ""
  end
  if phase_with_logs.has_key?("Commit")
    commit = phase_with_logs["Commit"].any? { |log| log[5] == "Error" } ? "Error" : "Succeeded"
  else
    commit = ""
  end

  counter += 1
  table_data << [counter, server, simulate, stage, commit]
end

pack_response "results", { :perPage => 10, :totalItems => table_data.count - 1, :data => table_data }

pack_response "results_link", results_full_path

raise "The Deploy job had errors!" if had_errors
