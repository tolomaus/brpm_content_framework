class PatchingJob < BsaSoapBase
  def internal_aix_execute(cmd, options = {})
    validate_cli_options_hash([:job_name, :group_name, :target, :catalog_name, :include_file, :exclude_file],options)
    b_key_result = execute_cli_with_param_list(self.class, cmd,
                                               [
                                                   options[:job_name],				# Name of job
                                                   options[:group_name],			# Parent group of the job
                                                   options[:target],				# Name of target (server, group, or smart group)
                                                   options[:catalog_name],			# Catalog name
                                                   options[:include_file],			# Include file path
                                                   options[:exclude_file],			# Exclude file path
                                                   options[:analysis_option] || 1,	# Analysis options:
                                                   #   1 - Use global settings (DEFAULT)
                                                   #   2 - Stop analysis if any applied fileset found
                                                   #   3 - Continue analysis even if applied fileset found
                                                   options[:analysis_mode] || 2	# Analysis mode:
                                               #   1 - Report on all missing filesets, the ones that are
                                               #       not install on the target
                                               #   2 - report only updates for the installed fileset on
                                               #       the target
                                               ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} #{cmd} Exception: #{exception.to_s}"
  end

  def internal_linux_execute(cmd, options = {})
    validate_cli_options_hash([:job_name, :group_name, :target, :catalog_name, :include_file, :exclude_file],options)
    db_key_result = execute_cli_with_param_list(self.class, cmd,
                                                [
                                                    options[:job_name],					# Name of job
                                                    options[:group_name],				# Parent group of the job
                                                    options[:target],					# Name of target (server, group, or smart group)
                                                    options[:catalog_name],				# Catalog name
                                                    options[:include_file],				# Include file path
                                                    options[:exclude_file],				# Exclude file path
                                                    options[:set_install_mode] || true,	# Install mode: true to set install mode, false otherwise
                                                    options[:set_exact_arch] || false	# Architecture: true to use exact architecture match, false otherwise
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} #{cmd} Exception: #{exception.to_s}"
  end

  def internal_redhat_execute(cmd, options = {})
    validate_cli_options_hash([:job_name, :group_name, :target],options)
    db_key_result = execute_cli_with_param_list(self.class, cmd,
                                                [
                                                    options[:job_name],					# Name of job
                                                    options[:group_name],				# Parent group of the job
                                                    options[:target],					# Name of target (server, group, or smart group)
                                                    options[:catalog_name] || "",		# Catalog name
                                                    options[:include_file] || "",		# Include file path
                                                    options[:exclude_file] || "",		# Exclude file path
                                                    options[:set_install_mode] || true	# Install mode: true to set install mode, false otherwise
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} #{cmd} Exception: #{exception.to_s}"
  end

  def internal_solaris_execute(cmd, options = {})
    validate_cli_options_hash([:job_name, :group_name, :target, :catalog_name, :include_file, :exclude_file],options)
    db_key_result = execute_cli_with_param_list(self.class, cmd,
                                                [
                                                    options[:job_name],						# Name of job
                                                    options[:group_name],					# Parent group of the job
                                                    options[:target],						# Name of target (server, group, or smart group)
                                                    options[:catalog_name],					# Catalog name
                                                    options[:include_file],					# Include file path
                                                    options[:exclude_file],					# Exclude file path
                                                    options[:recommended_only] || true,		# Analyze recommended patches only, false otherwise
                                                    options[:security_only] || false,		# Analyze security patches only, false otherwise
                                                    options[:without_dependencies] || false	# Analyze without dependencies, false otherwise
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} #{cmd} Exception: #{exception.to_s}"
  end

  def internal_windows_execute(cmd, options = {})
    validate_cli_options_hash([:job_name, :group_name, :target, :catalog_name, :include_file, :exclude_file],options)
    db_key_result = execute_cli_with_param_list(self.class, cmd,
                                                [
                                                    options[:job_name],									# Name of job
                                                    options[:group_name],								# Parent group of the job
                                                    options[:target],									# Name of target (server, group, or smart group)
                                                    options[:catalog_name],								# Catalog name
                                                    options[:include_file],								# Include file path
                                                    options[:exclude_file],								# Exclude file path
                                                    options[:analyze_security_tools] || true,			# Analyze security tools, false otherwise
                                                    options[:analyze_security_patches] || false,		# Analyze security patches, false otherwise
                                                    options[:analyze_non_security_patches] || false,	# Analyze non-security patches, false otherwise
                                                    options[:filter_service_packs] || false				# Filter services packs, false otherwise
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} #{cmd} Exception: #{exception.to_s}"
  end

  def create_aix_patching_job_with_target_group(options = {})
    db_key = self.internal_aix_execute("createAixPatchingJobWithTargetGroup", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_aix_patching_job_with_target_server(options = {})
    db_key = self.internal_aix_execute("createAixPatchingJobWithTargetServer", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_download_job_for_missing_patches(options = {})
    validate_cli_options_hash([:pa_job_run_key, :job_name, :dep_job_group_name],options)
    db_key_result = execute_cli_with_param_list(self.class, "createDownloadJobForMissingPatches",
                                                [
                                                    options[:pa_job_run_key],		# Handle to the patching job run
                                                    options[:job_name],				# Name of the download job
                                                    options[:dep_job_group_name]	# Name of a group that should contain the download job
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_other_linux_patching_job_with_target_group(options = {})
    db_key = self.internal_linux_execute("createOtherLinuxPatchingJobWithTargetGroup", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_other_linux_patching_job_with_target_server(options = {})
    db_key = self.internal_linux_execute("createOtherLinuxPatchingJobWithTargetServer", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_redhat_patching_job_with_target_group(options = {})
    db_key = self.internal_redhat_execute("createRedhatPatchingJobWithTargetGroup", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_redhat_patching_job_with_target_server(options = {})
    db_key = self.internal_redhat_execute("createRedhatPatchingJobWithTargetServer", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_solaris_patching_job_with_target_group(options = {})
    db_key = self.internal_solaris_execute("createSolarisPatchingJobWithTargetGroup", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_solaris_patching_job_with_target_server(options = {})
    db_key = self.internal_solaris_execute("createSolarisPatchingJobWithTargetServer", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_windows_patching_job_with_target_group(options = {})
    db_key = self.internal_windows_execute("createWindowsPatchingJobWithTargetGroup", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def create_windows_patching_job_with_target_server(options = {})
    db_key = self.internal_windows_execute("createWindowsPatchingJobWithTargetServer", options)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def delete_job_by_group_and_name(options = {})
    validate_cli_options_hash([:parent_group, :job_name],options)
    void_result = execute_cli_with_param_list(self.class, "deleteJobByGroupAndName",
                                              [
                                                  options[:parent_group],	# Fully qualifed path to the job group containing the patching job
                                                  options[:job_name]		# Name of the patching job
                                              ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def execute_job_and_wait(options = {})
    validate_cli_options_hash([:job_key],options)
    job_run_key_result = execute_cli_with_param_list(self.class, "executeJobAndWait",
                                                     [
                                                         options[:job_key]	# Handle to the patching job to execute
                                                     ])
    job_run_key = get_cli_return_value(job_run_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_dbkey_by_group_and_name(options = {})
    validate_cli_options_hash([:group_name, :job_name],options)
    db_key_result = execute_cli_with_param_list(self.class, "getDBKeyByGroupAndName",
                                                [
                                                    options[:group_name],	# Fully qualified path the the job group containing the job
                                                    options[:job_name]		# Name of the job
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def set_description(options = {})
    validate_cli_options_hash([:job_key, :desc],options)
    db_key_result = execute_cli_with_param_list(self.class, "setDescription",
                                                [
                                                    options[:job_key],	# the handle to the patching job
                                                    options[:job_name]	# the description for the job
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def set_remediation_options(options = {})
    validate_cli_options_hash([:patching_job_key, :pck_prefix, :depot_group_name, :depot_job_group_name],options)
    db_key_result = execute_cli_with_param_list(self.class, "setRemediationOptions",
                                                [
                                                    options[:patching_job_key],		# handle to the patching job
                                                    options[:pck_prefix],			# prefix for naming the new batch job/deploy job/package(s)
                                                    options[:depot_group_name],		# name of group that should contain the new package(s)
                                                    options[:depot_job_group_name]	# name of group that should contain the generated deploy job(s)
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def set_remediation_with_deploy_options(options = {})
    validate_cli_options_hash([:patching_job_key, :pck_prefix, :depot_group_name, :depot_job_group_name, :deploy_job_key],options)
    db_key_result = execute_cli_with_param_list(self.class, "setRemediationWithDeployOptions",
                                                [
                                                    options[:patching_job_key],		# handle to the patching job
                                                    options[:pck_prefix],			# prefix for naming the new batch job/deploy job/package(s)
                                                    options[:depot_group_name],		# name of group that should contain the new package(s)
                                                    options[:depot_job_group_name],	# name of group that should contain the generated deploy job(s)
                                                    options[:deploy_job_key]		# handle to the deploy job run whose options you want to use with
                                                #  generated deploy job(s)
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end
end