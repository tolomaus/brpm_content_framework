class JobManagement < BsaSoapBase
  def get_job_manager_full_status(options = {})
    string_result = execute_cli_with_param_list(self.class, "getJobManagerFullStatus")
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_job_manager_status(options = {})
    string_result = execute_cli_with_param_list(self.class, "getJobManagerStatus")
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def get_running_jobs_status(options = {})
    string_result = execute_cli_with_param_list(self.class, "getRunningJobsStatus")
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end
end