require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"
require "bladelogic/lib/bl_soap/patch"
require "bladelogic/lib/bl_soap/job"
require "bladelogic/lib/bl_soap/core"
require 'yaml'
require 'uri'
require 'base64'
require 'csv'
require 'date'

def retrieve_results(job, results_full_path, bsa_base_url, session_id, params)
  Logger.log("Removing trailing csv files in case this is a re-run...")
  `rm -f #{params["SS_output_dir"]}/*_result.csv`

  Logger.log("Retrieving the job run id from the job run key...")
  job_run_id = JobRun.get_deploy_job_max_run_id(bsa_base_url, session_id, {:db_key_of_deploy_job => job["db_key"]})

  Logger.log("Retrieving the results from the job run id...")
  return_data = Utility.export_deploy_script_run(bsa_base_url, session_id, {
      :job_group_name => job["group_name"],
      :job_name => job["name"],
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

  logs.compact # removing the possible nils from the array
end

def execute_script(params)
  request_params = get_request_params()
  raise "No job key found for a Patch Analysis job. A Patch Analysis job must be executed before a Patch Remediation job." if !request_params.has_key?("patch_analysis_job_run_key") or request_params["patch_analysis_job_run_key"].nil?

  BsaPatch.disable_verbose_logging

  bsa_base_url = params["SS_integration_dns"]
  bsa_username = params["SS_integration_username"]
  bsa_password = decrypt_string_with_prefix(params["SS_integration_password_enc"])
  bsa_role = params["SS_integration_details"]["role"]

  phase = params["phase_list"].index(params["phase"].strip)

  patch_remediation_depot_group = "/#{params["application"].downcase}/remediation"

  patch_remediation_job_root_path = "/#{params["application"].downcase}/remediation"
  patch_remediation_job_runs_path = "#{patch_remediation_job_root_path}/runs"
  patch_remediation_job_group = "#{phase}-job-#{params["request_id"]}-#{Time.now.strftime("%Y%m%d%H%M%S")}"
  patch_remediation_job_name = "#{phase}-job"
  patch_remediation_job_run_path = "#{patch_remediation_job_runs_path}/#{patch_remediation_job_group}"

  patch_remediation_job_template_group = patch_remediation_job_root_path
  patch_remediation_job_template_name = "#{phase}-job-template"

  Logger.log("Logging on to Bladelogic instance #{bsa_base_url} with user #{bsa_username} and role #{bsa_role}...")
  session_id = BsaPatch.login_with_role(bsa_base_url, bsa_username, bsa_password, bsa_role)

  Logger.log("Retrieving the job key of the Patch Remediation #{phase} job template...")
  job_template_db_key = DeployJob.get_dbkey_by_group_and_name(bsa_base_url, session_id, {:group_name => patch_remediation_job_template_group, :job_name => patch_remediation_job_template_name})

  Logger.log("Creating a new folder for the Patch Remediation #{phase} job...")
  JobGroup.create_group_with_parent_name(bsa_base_url, session_id, {:group_name => patch_remediation_job_group, :parent_group_name => patch_remediation_job_runs_path})

  unless phase == "commit"
    wait_time = 30
    start_time = Time.now + wait_time
    Logger.log("Scheduling the #{phase} phase of the Patch Remediation #{phase} job template to start in #{wait_time} seconds (at #{start_time.strftime("%Y-%m-%d %H:%M:%S")})...")
    DeployJob.set_phase_schedule_by_dbkey(bsa_base_url, session_id, {
        :job_run_key => job_template_db_key,
        :simulate_type => "AtTime",
        :simulate_date => start_time.strftime("%Y-%m-%d %H:%M:%S"),
        :stage_type => "AfterPreviousPhase",
        :stage_date => "",
        :commit_type => phase == "commit" ? "AfterPreviousPhase" : "NotScheduled",
        :commit_date => ""})
  end

  Logger.log("Creating the Patch Remediation job #{patch_remediation_job_runs_path}/#{patch_remediation_job_group}/#{patch_remediation_job_name} for Patch Analysis job run key #{request_params["patch_analysis_job_run_key"]}...")
  job_db_key = PatchRemediationJob.create_remediation_job_with_deploy_opts(bsa_base_url, session_id, {
      :remediation_name => patch_remediation_job_name,
      :job_group_name => patch_remediation_job_run_path,
      :pa_job_run_key => request_params["patch_analysis_job_run_key"],
      :pck_prefix => patch_remediation_job_name,
      :depot_group_name => patch_remediation_depot_group,
      :dep_job_group_name => patch_remediation_job_run_path,
      :deploy_job_key => job_template_db_key})

  Logger.log("Executing the Patch Remediation job...")
  job_run_key = PatchRemediationJob.execute_job_and_wait(bsa_base_url, session_id, {:job_key => job_db_key})

  unless phase =="commit"
    Logger.log("Polling the Patch Remediation job until it is finished...")
    begin
       sleep(wait_time)
       is_still_running = JobRun.get_job_run_is_running_by_run_key(bsa_base_url, session_id, {:job_run_key => job_run_key})
    end while is_still_running
    Logger.log("The Patch Remediation job has finished.")
  end

  Logger.log("Checking if the Patch Remediation job finished successfully...")
  had_errors = JobRun.get_job_run_had_errors(bsa_base_url, session_id, {:job_run_key => job_run_key})

  had_errors ? Logger.log("WARNING: The Patch Remediation job had errors!") : Logger.log("The Patch Remediation job had no errors.")
  pack_response "job_status", had_errors ? "The job had errors" : "The job ran successfully"

  raise "The Patch Remediation job had errors!" if had_errors

  Logger.log("Retrieving all the generated jobs from group #{patch_remediation_job_run_path}...")
  jobs = Job.list_all_by_group(bsa_base_url, session_id, {:group_name => patch_remediation_job_run_path})

  job_names = jobs.split("\n")
  job_names = job_names.reject{|job| job == patch_remediation_job_name or job.include?(" batch deploy ")}.sort

  Logger.log("Retrieving the job run keys of the generated jobs...")
  jobs = {}
  job_names.each do |job_name|
    jobs[job_name] = {}
    jobs[job_name]["name"] = job_name
    jobs[job_name]["group_name"] = patch_remediation_job_run_path

    Logger.log("Retrieving the job run key of job #{job_name}...")
    jobs[job_name]["db_key"] = DeployJob.get_dbkey_by_group_and_name(bsa_base_url, session_id, {:group_name => patch_remediation_job_run_path, :job_name => job_name})
    jobs[job_name]["run_key"] = JobRun.find_last_run_key_by_job_key(bsa_base_url, session_id, {:job_key => jobs[job_name]["db_key"]})
  end

  Logger.log("Polling the generated jobs until they are finished...")
  running_jobs = jobs
  begin
    finished_jobs = {}
    running_jobs.each do |key, job|
      is_still_running = JobRun.get_job_run_is_running_by_run_key(bsa_base_url, session_id, {:job_run_key => job["run_key"]})

      unless is_still_running
        Logger.log("The job with run key #{job["run_key"]} has finished, retrieving its results...")
        job["results"] = retrieve_results(job, "#{params["SS_output_dir"]}/#{job["name"]}_result.csv", bsa_base_url, session_id, params)

        finished_jobs[key] = job
      end
    end

    running_jobs = running_jobs.reject { |key, job| finished_jobs.has_key?(key) }

    sleep(10) if running_jobs.count > 0
  end while running_jobs.count > 0

  Logger.log("Processing the job results into one view...")
  logs = jobs.values.reduce([]){ |results,job| results + job["results"] }

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

  Logger.log("Concatenating the result files into one file...")
  results_full_path = "#{params["SS_output_dir"]}/all_jobs_result.csv"

  `cat #{params["SS_output_dir"]}/*_result.csv >> #{results_full_path}`

  pack_response "results_link", results_full_path

  raise "The Patch Remediation job had errors!" if had_errors
end