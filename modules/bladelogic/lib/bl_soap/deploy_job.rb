# very basic support right now
class DeployJob < BsaSoapBase
  def create_deploy_job(options = {})
    validate_cli_options_hash([:job_name, :group_id, :package_db_key, :server_name], options)
    db_key_result = execute_cli_with_param_list(self.class, "createDeployJob",
                                                [
                                                    options[:job_name],
                                                    options[:group_id],
                                                    options[:package_db_key],
                                                    options[:server_name],
                                                    true, #isSimulateEnabled
                                                    true, #isCommitEnabled
                                                    false, #isStagedIndirect
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "Exception executing #{self.class} function: #{exception.to_s}"
  end

  def get_dbkey_by_group_and_name(options = {})
    validate_cli_options_hash([:group_name, :job_name], options)
    db_key_result = execute_cli_with_param_list(self.class, "getDBKeyByGroupAndName",
                                                [
                                                    options[:group_name],	# Fully qualified path to the job group containing the job
                                                    options[:job_name]		# Name of the job
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "Exception executing #{self.class} function: #{exception.to_s}"
  end

  def set_phase_schedule_by_dbkey(options = {})
    validate_cli_options_hash([:job_run_key], options)
    void_result = execute_cli_with_param_list(self.class, "setAdvanceDeployJobPhaseScheduleByDBKey",
                                              [
                                                  options[:job_run_key],
                                                  options[:simulate_type],
                                                  options[:simulate_date],
                                                  options[:stage_type],
                                                  options[:stage_date],
                                                  options[:commit_type],
                                                  options[:commit_date],
                                              ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end
end