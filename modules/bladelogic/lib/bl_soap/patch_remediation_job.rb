class PatchRemediationJob < BsaSoapBase
  def create_remediation_job(options)
    validate_cli_options_hash(
        [:remediation_name, :job_group_name, :pa_job_run_key, :pck_prefix, :depot_group_name, :dep_job_group_name],
        options)

    puts "Content from bsa_patch_utils "
    options.each_pair {|key,value| puts  "#{key} = #{value}" }

    db_key_result = execute_cli_with_param_list(self.class, "createRemediationJob",
                                                [
                                                    options[:remediation_name],		# Name of the job
                                                    options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
                                                    options[:pa_job_run_key],		# Handle to the job run whose result you want to use for remediation
                                                    options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
                                                    options[:depot_group_name],		# Name of a group that should contain the new Package(s)
                                                    options[:dep_job_group_name]	# Name of a group that should contain the generated Deploy Job(s)
                                                ])

    db_key = get_cli_return_value(db_key_result)

  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_remediation_job_for_a_target(options)
    validate_cli_options_hash(
        [:remediation_name, :job_group_name, :pa_job_run_key, :server_name, :pck_prefix, :depot_group_name, :dep_job_group_name],
        options)
    db_key_result = execute_cli_with_param_list(self.class, "createRemediationJobForATarget",
                                                [
                                                    options[:remediation_name],		# Name of the job
                                                    options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
                                                    options[:pa_job_run_key],		# Handle to the job run whose result you want to use for remedation
                                                    options[:server_name],			# Server where you want to run this job, should be one of the server where analysis was run
                                                    options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
                                                    options[:depot_group_name],		# Name of a group that should contain the new Package(s)
                                                    options[:dep_job_group_name]	# Name of a group that should contain the generated Deploy Job(s)
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_remediation_job_with_deploy_opts(options)
    validate_cli_options_hash(
        [:remediation_name, :job_group_name, :pa_job_run_key, :pck_prefix, :depot_group_name, :dep_job_group_name, :deploy_job_key],
        options)
    db_key_result = execute_cli_with_param_list(self.class, "createRemediationJobWithDeployOpts",
                                                [
                                                    options[:remediation_name],		# Name of the job
                                                    options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
                                                    options[:pa_job_run_key],		# Hand to the patching job run whose results you want to use for remediation
                                                    options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
                                                    options[:depot_group_name],		# Name of a group that should contain the new Package(s)
                                                    options[:dep_job_group_name],	# Name of a group that should contain the new generated Deploy Job(s)
                                                    options[:deploy_job_key]		# Handle to the Deploy Job run whose options you want to use generated Deploy Job(s)
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_remediation_job_with_deploy_opts_for_a_target(options)
    validate_cli_options_hash(
        [:remediation_name, :job_group_name, :pa_job_run_key, :server_name, :pck_prefix, :depot_group_name, :dep_job_group_name, :deploy_job_key],
        options)
    db_key_result = execute_cli_with_param_list(self.class, "createRemediationJobWithDeployOpts",
                                                [
                                                    options[:remediation_name],		# Name of the job
                                                    options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
                                                    options[:pa_job_run_key],		# Hand to the patching job run whose results you want to use for remediation
                                                    options[:server_name],			# Server where you want to run this job.  Server should  be a server which had an anaylsis run
                                                    options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
                                                    options[:depot_group_name],		# Name of a group that should contain the new Package(s)
                                                    options[:dep_job_group_name],	# Name of a group that should contain the new generated Deploy Job(s)
                                                    options[:deploy_job_key]		# Handle to the Deploy Job run whose options you want to use generated Deploy Job(s)
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def modify_job_set_(options)
    validate_cli_options_hash(
        [:remediation_name, :job_group_name, :pa_job_run_key, :server_name, :pck_prefix, :depot_group_name, :dep_job_group_name, :deploy_job_key],
        options)
    db_key_result = execute_cli_with_param_list(self.class, "createRemediationJobWithDeployOpts",
                                                [
                                                    options[:remediation_name],		# Name of the job
                                                    options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
                                                    options[:pa_job_run_key],		# Hand to the patching job run whose results you want to use for remediation
                                                    options[:server_name],			# Server where you want to run this job.  Server should  be a server which had an anaylsis run
                                                    options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
                                                    options[:depot_group_name],		# Name of a group that should contain the new Package(s)
                                                    options[:dep_job_group_name],	# Name of a group that should contain the new generated Deploy Job(s)
                                                    options[:deploy_job_key]		# Handle to the Deploy Job run whose options you want to use generated Deploy Job(s)
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def execute_job_and_wait(options)
    validate_cli_options_hash([:job_key], options)
    job_run_key_result = execute_cli_with_param_list(self.class, "executeJobAndWait",
                                                     [
                                                         options[:job_key]	# Handle to the remediation job to be executed
                                                     ])
    job_run_key = get_cli_return_value(job_run_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def execute_job_get_job_result_key(options)
    validate_cli_options_hash([:job_key], options)
    db_key_result = execute_cli_with_param_list(self.class, "executeJobGetJobResultKey",
                                                [
                                                    options[:job_key]	# Handle to the remediation job to be executed
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_dbkey_by_group_and_name(options)
    validate_cli_options_hash([:group_name, :job_name], options)
    db_key_result = execute_cli_with_param_list(self.class, "getDBKeyByGroupAndName",
                                                [
                                                    options[:group_name],	# Fully qualified path to the job group containing the job
                                                    options[:job_name]		# Name of the job
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end
end