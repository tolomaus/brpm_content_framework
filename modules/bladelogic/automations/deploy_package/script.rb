require "brpm/lib/brpm_rest_api"
require "bladelogic/lib/bl_soap/core"
require "bladelogic/lib/bl_soap/component"
require "bladelogic/lib/bl_soap/depot"
require "bladelogic/lib/bl_soap/blpackage"
require "bladelogic/lib/bl_soap/job"
require "bladelogic/lib/bl_rest/component"

def execute_script(params)
  BsaSoap.disable_verbose_logging

  bsa_base_url = params["SS_integration_dns"]
  bsa_username = params["SS_integration_username"]
  bsa_password = decrypt_string_with_prefix(params["SS_integration_password_enc"])
  bsa_role = params["SS_integration_details"]["role"]

  Logger.log("Getting the server group from the step...")
  server_group = get_server_group_from_step_id(params["step_id"])
  params["server_group"] = server_group if server_group # this param may be needed for the tokenizing below

  target_type = first_defined(sub_tokens(params, params["target_type"]), "Server group")
  target_path = first_defined(sub_tokens(params, params["target_path"]), "/Applications/#{params["application"]}/#{params["request_environment"]}/#{server_group}")

  deploy_job_name = first_defined(sub_tokens(params, params["deploy_job_name"]), "Deploy #{params["component"]} #{params["component_version"]} in #{params["request_environment"]} - #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}")
  deploy_job_group_path = first_defined(sub_tokens(params, params["deploy_job_group_path"]), "/Applications/#{params["application"]}")

  depot_group_path = first_defined(sub_tokens(params, params["depot_group_path"]), "/Applications/#{params["application"]}/#{params["component"]}")
  package_name = first_defined(sub_tokens(params, params["bl_package_name"]), params["component_version"])

  Logger.log("Logging on to Bladelogic instance #{bsa_base_url} with user #{bsa_username} and role #{bsa_role}...")
  session_id = BsaSoap.login_with_role(bsa_base_url, bsa_username, bsa_password, bsa_role)

  Logger.log("Retrieving the db key of blpackage #{depot_group_path}/#{package_name}...")
  package_db_key = BlPackage.get_dbkey_by_group_and_name(bsa_base_url, session_id, {:parent_group => depot_group_path, :depot_group_path => package_name })

  Logger.log("Retrieving the id of job group #{deploy_job_group_path}...")
  deploy_job_group_id = JobGroup.group_name_to_id(bsa_base_url, session_id, {:group_name => deploy_job_group_path })

  Logger.log("Creating Deploy job #{deploy_job_group_path}/#{deploy_job_name}...")
  job_db_key = DeployJob.create_deploy_job(bsa_base_url, session_id, {:job_name => deploy_job_name, :group_id => deploy_job_group_id, :package_db_key => package_db_key, :server_name => "localhost" })

  Logger.log("Cleaning the servers from the Deploy job...")
  job_db_key = Job.clear_target_servers(bsa_base_url, session_id, {:job_key => job_db_key})

  if target_type == "Server group"
    Logger.log("Adding server group #{target_path} to the Deploy job...")
    job_db_key = Job.add_target_group(bsa_base_url, session_id, {:job_key => job_db_key, :group_name => target_path})
  elsif target_type == "Component group"
    Logger.log("Adding component group #{target_path} to the Deploy job...")
    job_db_key = Job.add_target_component_group(bsa_base_url, session_id, {:job_key => job_db_key, :group_name => target_path})
  end

  Logger.log("Executing the Deploy job...")
  job_run_key = Job.execute_job_and_wait(bsa_base_url, session_id, {:job_key => job_db_key})
  Logger.log("Job run key is #{job_run_key}.")

  Logger.log("Checking if the job finished successfully...")
  had_errors = JobRun.get_job_run_had_errors(bsa_base_url, session_id, {:job_run_key => job_run_key})

  had_errors ? Logger.log("WARNING: The job had errors!") : Logger.log("The job had no errors.")
  pack_response "job_status", had_errors ? "The job had errors" : "The job ran successfully"

  Logger.log("Retrieving the job run id from the job run key...")
  job_run_id = JobRun.job_run_key_to_job_run_id(bsa_base_url, session_id, {:job_run_key => job_run_key})

  results_full_path = "#{params["SS_output_dir"]}/#{deploy_job_name}_result.csv"

  Logger.log("Retrieving the results from the job run id...")
  return_data = Utility.export_deploy_script_run(bsa_base_url, session_id, {
                                                                 :job_group_name => deploy_job_group_path,
                                                                 :job_name => deploy_job_name,
                                                                 :run_id => job_run_id,
                                                                 :export_file_name => results_full_path})
  results_content = Base64.decode64(return_data)

  File.open(results_full_path, "w") do |f|
    f.puts(results_content)
  end

  Logger.log("Parsing the results...")
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

  raise "The Patch Remediation job had errors!" if had_errors
end