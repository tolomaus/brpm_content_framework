require 'base64'
require 'csv'
require 'date'

def pack_response_for_result_summaries(csv_content)
  logs = csv_content[6..-1] # remove the headers of the csv file

  logs = logs.select { |log| !log[0].start_with?("Run at") }

  logs.each do |log|
    log[2] = DateTime.parse(log[2])
  end

  logs = logs.sort_by { |log| [log[0], log[2]] }

  servers_with_logs = logs.group_by {|log| log[0] }
  failed_servers_with_logs = servers_with_logs.select {|key, value| value.select{|log| log[1] == "Error"}.count>0}

  pack_response "results_summary", "#{servers_with_logs.count - failed_servers_with_logs.count}/#{servers_with_logs.count} servers were successful"

  table_data = [[' ', 'Server', 'Result', 'Error message']]
  counter = 0
  server_cache = ""
  logs.select{|log| log[1] == "Error"}.each do |log|
    if log[0] == server_cache
      server = ""
    else
      server = log[0]
      server_cache = log[0]
    end
    result = log[1]
    message = log[3]

    counter += 1
    table_data << [counter, server, result, message]
  end

  pack_response "failed_servers", { :perPage => 10, :totalItems => table_data.count - 1, :data => table_data }
end

def execute_script(params)
  BrpmAuto.log("Getting the server group from the step...")
  server_group = "/#{get_server_group_from_step_id(params["step_id"])}"

  job_type_and_name = params["job_type_and_name"].split("|")
  job_type = job_type_and_name[0]
  job_name = job_type_and_name[1]
  raise "Could not find out the job key or job name." unless job_type_and_name.count == 2

  job_group = "/#{params["application"].downcase}/public/#{job_type}"
  BrpmAuto.log("The job to be executed is  #{job_group}/#{job_name}")

  BrpmAuto.log("Logging on to Bladelogic instance #{BsaSoap.get_url} with user #{BsaSoap.get_username} and role #{BsaSoap.get_role}...")
  session_id = BsaSoap.login

  BrpmAuto.log("Retrieving the job key of the job...")
  job_db_key = Object.const_get(job_type).get_dbkey_by_group_and_name(session_id, {:group_name => job_group, :job_name => job_name})
  BrpmAuto.log("Job key is #{job_db_key}.")

#  BrpmAuto.log("Cleaning the servers from the job...")
#  job_db_key = Job.clear_target_servers(session_id, {:job_key => job_db_key})

#  BrpmAuto.log("Cleaning the server groups from the job...")
#  job_db_key = Job.clear_target_groups(session_id, {:job_key => job_db_key})

  BrpmAuto.log("Executing the job on server group #{server_group}...")
  job_run_key = Job.execute_against_server_groups_for_run_id(session_id, {:job_key => job_db_key, :server_groups => server_group})
  BrpmAuto.log("Job run is #{job_run_key}.")

  BrpmAuto.log("Polling the job until it is finished...")
  begin
    sleep(10)
    is_still_running = JobRun.get_job_run_is_running_by_run_key(session_id, {:job_run_key => job_run_key})
  end while is_still_running
  BrpmAuto.log("The job has finished.")

  BrpmAuto.log("Checking if the job finished successfully...")
  had_errors = JobRun.get_job_run_had_errors(session_id, {:job_run_key => job_run_key})

  had_errors ? BrpmAuto.log("WARNING: The job had errors!") : BrpmAuto.log("The job had no errors.")
  pack_response "job_status", had_errors ? "The job had errors" : "The job ran successfully"

  BrpmAuto.log("Retrieving the job run id from the job run key...")
  job_run_id = JobRun.job_run_key_to_job_run_id(session_id, {:job_run_key => job_run_key})

  BrpmAuto.log("Retrieving the results from the job run id...")
  results_full_path = "#{params["SS_output_dir"]}/#{job_name}_result.csv"
  return_data = Utility.export_nsh_script_run(session_id, {
      :run_id => job_run_id,
      :export_file_name => results_full_path})
  results_content = Base64.decode64(return_data)

  File.open(results_full_path, "w") do |f|
    f.puts(results_content)
  end

  csv_content = CSV.parse(results_content)

  pack_response_for_result_summaries(csv_content)

  pack_response "results_link", results_full_path

  raise "The job had errors!" if had_errors
end