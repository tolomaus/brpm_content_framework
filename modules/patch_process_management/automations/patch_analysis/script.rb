require "framework/lib/request_params"
require "brpm/lib/brpm_rest_client"
require "bladelogic/lib/bl_soap/patch_catalog"
require "bladelogic/lib/bl_soap/job"
require "bladelogic/lib/bl_soap/bsa_soap_client"
require "bladelogic/lib/bl_soap/utility"
require 'yaml'
require 'uri'
require 'base64'
require 'csv'

def extract_table_data(csv_content)
  patches = csv_content[12..-1] # remove the headers of the csv file

  patches = patches.sort_by { |patch| [patch[1], patch[2]] }

  table_data = [[' ', 'Server', 'Package']]
  counter = 0
  server_cache = ""

  patches.each do |patch|
    if patch[1] == server_cache
      server = ""
    else
      server = patch[1]
      server_cache = patch[1]
    end

    if patch[0] == "Failed"
      package = "Failed"
    elsif patch[2] == "NO-PATCH-MISSING"
      package = "Already up-to-date"
    else
      package = patch[2]
    end

    counter += 1
    table_data << [counter, server, package]
  end
  return table_data
end

def execute_script(params)
  BrpmAuto.log("Getting the server group from the step...")
  server_group = "/#{get_server_group_from_step_id(params["step_id"])}"

  patch_analysis_job_group = "/patch-process-management"
  patch_analysis_job_name = "analysis-job"

  BrpmAuto.log("Logging on to Bladelogic instance #{BsaSoapClient.get_url} with user #{BsaSoapClient.get_username} and role #{BsaSoapClient.get_role}...")
  session_id = BsaSoapClient.login

  BrpmAuto.log("Retrieving the job key of Patch Analysis job #{patch_analysis_job_group}/#{patch_analysis_job_name}...")
  job_db_key = PatchingJob.get_dbkey_by_group_and_name(session_id, {:group_name => patch_analysis_job_group, :job_name => patch_analysis_job_name})
  BrpmAuto.log("Job key is #{job_db_key}.")

#  BrpmAuto.log("Cleaning the servers from the Patch Analysis job...")
#  job_db_key = Job.clear_target_servers(session_id, {:job_key => job_db_key})

#  BrpmAuto.log("Cleaning the server groups from the Patch Analysis job...")
#  job_db_key = Job.clear_target_groups(session_id, {:job_key => job_db_key})

  BrpmAuto.log("Executing the Patch Analysis job on server group #{server_group}...")
  job_run_key = Job.execute_against_server_groups_for_run_id(session_id, {:job_key => job_db_key, :server_groups => server_group})
  BrpmAuto.log("Job run is #{job_run_key}.")

  BrpmAuto.log("Polling the Patch Analysis job until it is finished...")
  begin
    sleep(10)
    is_still_running = JobRun.get_job_run_is_running_by_run_key(session_id, {:job_run_key => job_run_key})
  end while is_still_running
  BrpmAuto.log("The Patch Analysis job has finished.")

  BrpmAuto.log("Checking if the Patch Analysis job finished successfully...")
  had_errors = JobRun.get_job_run_had_errors(session_id, {:job_run_key => job_run_key})

  had_errors ? BrpmAuto.log("WARNING: The Patch Analysis job had errors!") : BrpmAuto.log("The Patch Analysis job had no errors.")
  pack_response "job_status", had_errors ? "The job had errors" : "The job ran successfully"

  BrpmAuto.log("Storing the job key and job run key of the Patch Analysis job for later reference...")
  add_request_param("patch_analysis_job_db_key", job_db_key)
  add_request_param("patch_analysis_job_run_key", job_run_key)

  BrpmAuto.log("Retrieving the job run id from the job run key...")
  job_run_id = JobRun.job_run_key_to_job_run_id(session_id, {:job_run_key => job_run_key})

  BrpmAuto.log("Retrieving the results from the job run id...")
  results_full_path = "#{params["SS_output_dir"]}/#{patch_analysis_job_name}_result.csv"
  return_data = Utility.export_patch_analysis_run(session_id, {
      :server_name => "",
      :job_group_name => patch_analysis_job_group,
      :job_name => patch_analysis_job_name,
      :run_id => job_run_id,
      :export_file_name => results_full_path,
      :export_type => "CSV"})
  results_content = Base64.decode64(return_data)

  File.open(results_full_path, "w") do |f|
    f.puts(results_content)
  end

  csv_content = CSV.parse(results_content)

  pack_response "results_summary", "#{csv_content[4][1]} RPM's missing, #{csv_content[5][1]} Errata's missing,  #{csv_content[7][1]}/#{csv_content[6][1].to_i + csv_content[7][1].to_i} servers were analyzed successfully"

  table_data = extract_table_data(csv_content)

  pack_response "results", { :perPage => 10, :totalItems => table_data.count - 1, :data => table_data }
  pack_response "results_link", results_full_path

  raise "The Patch Analysis job had errors!" if had_errors
end