require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"
require "bladelogic/lib/bl_soap/compliance"
require "bladelogic/lib/bl_soap/job"
require "bladelogic/lib/bl_soap/core"
require 'yaml'
require 'uri'
require 'base64'
require 'csv'

def extract_table_data(csv_content)
  checks = csv_content[14..-1] # remove the headers of the csv file

  checks = checks.sort_by { |check| check[1] }

  table_data = [[' ', 'Server', 'Rule', 'Result', 'Error message']]
  counter = 0
  checks.each do |check|
    server = check[1]
    rule = check[4]
    result = check[8]
    error_message = check[9]
    counter += 1
    table_data << [counter, server, rule, result, error_message]
  end
  return table_data
end

def execute_script(params)
  BsaCompliance.disable_verbose_logging

  bsa_base_url = params["SS_integration_dns"]
  bsa_username = params["SS_integration_username"]
  bsa_password = decrypt_string_with_prefix(params["SS_integration_password_enc"])
  bsa_role = params["SS_integration_details"]["role"]

  Logger.log("Getting the server group from the step...")
  server_group = "/#{get_server_group_from_step_id(params["step_id"])}"

  patch_readiness_job_group = "/patch-process-management"
  patch_readiness_job_name = "readiness-job"

  Logger.log("Logging on to Bladelogic instance #{bsa_base_url} with user #{bsa_username} and role #{bsa_role}...")
  session_id = BsaCompliance.login_with_role(bsa_base_url, bsa_username, bsa_password, bsa_role)

  Logger.log("Retrieving the job key of Patch Readiness job #{patch_readiness_job_group}/#{patch_readiness_job_name}...")
  job_db_key = ComplianceJob.get_dbkey_by_group_and_name(bsa_base_url, session_id, {:group_name => patch_readiness_job_group, :job_name => patch_readiness_job_name})
  Logger.log("Job key is #{job_db_key}.")

#  Logger.log("Cleaning the servers from the Patch Readiness job...")
#  job_db_key = Job.clear_target_servers(bsa_base_url, session_id, {:job_key => job_db_key})

#  Logger.log("Cleaning the server groups from the Patch Readiness job...")
#  job_db_key = Job.clear_target_groups(bsa_base_url, session_id, {:job_key => job_db_key})

  Logger.log("Executing the Patch Readiness job on server group #{server_group}...")
  job_run_key = Job.execute_against_server_groups_for_run_id(bsa_base_url, session_id, {:job_key => job_db_key, :server_groups => server_group})
  Logger.log("Job run is #{job_run_key}.")

  Logger.log("Polling the Patch Readiness job until it is finished...")
  begin
    sleep(10)
    is_still_running = JobRun.get_job_run_is_running_by_run_key(bsa_base_url, session_id, {:job_run_key => job_run_key})
  end while is_still_running
  Logger.log("The Patch Readiness job has finished.")

  Logger.log("Checking if the Patch Readiness job finished successfully...")
  had_errors = JobRun.get_job_run_had_errors(bsa_base_url, session_id, {:job_run_key => job_run_key})

  had_errors ? Logger.log("WARNING: The Patch Readiness job had errors!") : Logger.log("The Patch Readiness job had no errors.")
  pack_response "job_status", had_errors ? "The job had errors" : "The job ran successfully"

  Logger.log("Retrieving the job run id from the job run key...")
  job_run_id = JobRun.job_run_key_to_job_run_id(bsa_base_url, session_id, {:job_run_key => job_run_key})

  Logger.log("Retrieving the results from the job run id...")
  results_full_path = "#{params["SS_output_dir"]}/#{patch_readiness_job_name}_result.csv"
  return_data = Utility.export_compliance_run(bsa_base_url, session_id, {
      :job_group_name => patch_readiness_job_group,
      :job_name => patch_readiness_job_name,
      :run_id => job_run_id,
      :export_file_name => results_full_path,
      :export_type => "CSV"})
  results_content = Base64.decode64(return_data)

  File.open(results_full_path, "w") do |f|
    f.puts(results_content)
  end

  csv_content = CSV.parse(results_content)

  pack_response "results_summary", "#{csv_content[7][1]} / #{csv_content[6][1]} rules passed"

  table_data = extract_table_data(csv_content)

  pack_response "results", { :perPage => 10, :totalItems => table_data.count - 1, :data => table_data }
  pack_response "results_link", results_full_path

  raise "The Patch Readiness job had errors!" if had_errors
end