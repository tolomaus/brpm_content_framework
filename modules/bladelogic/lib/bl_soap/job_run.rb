class JobRun < BsaSoapBase
  def change_priority_of_running_job_by_job_run_id(options = {})
    validate_cli_options_hash([:job_run_id, :priority_string], options)
    void_result = execute_cli_with_param_list(self.class, "changePriorityOfRunningJobByJobRunId",
                                              [
                                                  options[:job_run_id],		# Job run ID number
                                                  options[:priority_string]	# Priority to change job run to
                                              ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def find_all_run_keys_by_job_key(options = {})
    validate_cli_options_hash([:job_key], options)
    string_result = execute_cli_with_param_list(self.class, "findAllRunKeysByJobKey",
                                                [
                                                    options[:job_key]	# DBKey key for the job
                                                ])
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def find_last_run_key_by_job_key(options = {})
    validate_cli_options_hash([:job_key], options)
    db_key_result = execute_cli_with_param_list(self.class, "findLastRunKeyByJobKey",
                                                [
                                                    options[:job_key],							# DBKey for the job
                                                # NIEK options[:exclude_deploy_attempts] || false	# Exclude deploy attempt run id
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def find_last_run_key_by_job_key_ignore_version(options = {})
    validate_cli_options_hash([:job_key], options)
    db_key_result = execute_cli_with_param_list(self.class, "findLastRunKeyByJobKeyIgnoreVersion",
                                                [
                                                    options[:job_key]	# DBKey for the job
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def find_run_count_by_job_key(options = {})
    validate_cli_options_hash([:job_key], options)
    integer_result = execute_cli_with_param_list(self.class, "findRunCountByJobKey",
                                                 [
                                                     options[:job_key]	# DBKey for the job
                                                 ])
    integer_value = get_cli_return_value(integer_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def find_run_key_by_id(options = {})
    #findRunKeyById_1 is deprecated => No support for job_key option
    validate_cli_options_hash([:job_run_id], options)
    db_key_result = execute_cli_with_param_list(self.class, "findRunKeyById",
                                                [
                                                    options[:job_run_id]	# Run number of the job run
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_aborted_job_runs_by_end_date(options = {})
    validate_cli_options_hash([:end_type], options)
    string_result = execute_cli_with_param_list(self.class, "getAbortedJobRunsByEndDate",
                                                [
                                                    options[:end_time]	# Time to use as the earliest end date, only runs aborted after this date will be shown
                                                ])
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_end_time_by_run_key(options = {})
    validate_cli_options_hash([:job_run_key], options)
    object_result = execute_cli_with_param_list(self.class, "getEndTimeByRunKey",
                                                [
                                                    options[:job_run_key],						# Handle identifying a particular job run
                                                    options[:format] || "yyyy/MM/dd HH:mm:ss"	# Format for presenting time
                                                ])
    object_value = get_cli_return_value(object_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_executing_user_and_role_by_run_key(options = {})
    validate_cli_options_hash([:job_run_key], options)
    string_result = execute_cli_with_param_list(self.class, "getExecutingUserAndRoleByRunKey",
                                                [
                                                    options[:job_run_key]	# Handle identifying a particular job run
                                                ])
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_job_run_had_errors(options = {})
    # getJobRunHadErrors_1 deprecated => No support
    validate_cli_options_hash([:job_run_key], options)
    boolean_result = execute_cli_with_param_list(self.class, "getJobRunHadErrors",
                                                 [
                                                     options[:job_run_key]	# Handle identifying a particular job run
                                                 ])
    boolean_value = get_cli_return_value(boolean_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_job_run_had_errors_by_id(options = {})
    validate_cli_options_hash([:job_run_id], options)
    boolean_result = execute_cli_with_param_list(self.class, "getJobRunHadErrorsById",
                                                 [
                                                     options[:job_run_id]	# Run ID for the job run
                                                 ])
    boolean_value = get_cli_return_value(boolean_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_job_run_is_running_by_run_key(options = {})
    validate_cli_options_hash([:job_run_key], options)
    boolean_result = execute_cli_with_param_list(self.class, "getJobRunIsRunningByRunKey",
                                                 [
                                                     options[:job_run_key]	# Handle identifying a particular job run
                                                 ])
    boolean_value = get_cli_return_value(boolean_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_job_run_status_by_schedule_id(options = {})
    validate_cli_options_hash([:schedule_id], options)
    string_result = execute_cli_with_param_list(self.class, "getJobRunStatusByScheduleId",
                                                [
                                                    options[:schedule_id]	# Handle identifying a particular job run
                                                ])
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_log_items_by_job_run_id(options = {})
    validate_cli_options_hash([:job_key, :job_run_id], options)
    string_result = execute_cli_with_param_list(self.class, "getLogItemsByJobRunId",
                                                [
                                                    options[:job_key],		# DB Key of the job
                                                    options[:job_run_id]	# Job run ID number
                                                ])
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_servers_status_by_job_run(options = {})
    validate_cli_options_hash([:job_run_id], options)
    map_result = execute_cli_with_param_list(self.class, "getServerStatusByJobRun",
                                             [
                                                 options[:job_run_id]	# Job run ID number
                                             ])
    map_value = get_cli_return_value(map_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_start_time_by_run_key(options = {})
    validate_cli_options_hash([:job_run_key], options)
    object_result = execute_cli_with_param_list(self.class, "getStartTimeByRunKey",
                                                [
                                                    options[:job_run_key],						# Handle identifying a particular job run
                                                    options[:format] || "yyyy/MM/dd HH:mm:ss"	# Format for presenting time
                                                ])
    object_value = get_cli_return_value(object_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def job_run_key_to_job_run_id(options = {})
    validate_cli_options_hash([:job_run_key], options)
    integer_result = execute_cli_with_param_list(self.class, "jobRunKeyToJobRunId",
                                                 [
                                                     options[:job_run_key]	# Handle identifying a particular job run
                                                 ])
    integer_value = get_cli_return_value(integer_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def pause_running_job_by_job_run_key(options = {})
    validate_cli_options_hash([:job_run_key], options)
    void_result = execute_cli_with_param_list(self.class, "pauseRunningJobByJobRunKey",
                                              [
                                                  options[:job_run_key]	# Handle identifying a particular job run
                                              ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def resume_paused_job_by_job_run_key(options = {})
    validate_cli_options_hash([:job_run_key], options)
    void_result = execute_cli_with_param_list(self.class, "resumePausedJobByJobRunKey",
                                              [
                                                  options[:job_run_key]	# Handle identifying a particular job run
                                              ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def show_all_running_batch_job_run_status(options = {})
    void_result = execute_cli_with_param_list(self.class, "showAllRunningBatchJobRunStatus")
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def show_all_running_post_prov_batch_job_run_status(options = {})
    list_result = execute_cli_with_param_list(self.class, "showAllRunningPostProvBatchJobRunStatus")
    list_value = get_cli_return_value(list_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def show_batch_job_run_status_by_run_id(options = {})
    validate_cli_options_hash([:run_id], options)
    void_result = execute_cli_with_param_list(self.class, "showBatchJobRunStatusByRunId",
                                              [
                                                  options[:run_id]	# Handle identifying a particular job run
                                              ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def show_batch_job_run_status_by_run_key(options = {})
    validate_cli_options_hash([:job_run_key], options)
    void_result = execute_cli_with_param_list(self.class, "showBatchJobRunStatusByRunId",
                                              [
                                                  options[:job_run_key]	# Handle identifying a particular job run
                                              ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def show_running_jobs(options = {})
    void_result = execute_cli_with_param_list(self.class, "showRunningJobs")
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_deploy_job_max_run_id(options = {})
    validate_cli_options_hash([:db_key_of_deploy_job], options)
    void_result = execute_cli_with_param_list(self.class, "getDeployJobMaxRunId",
                                              [
                                                  options[:db_key_of_deploy_job]	# Handle identifying a particular job run
                                              ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end
end