class JobResult < BsaSoapBase
  def find_job_result_key(options = {})
    validate_cli_options_hash([:job_run_key], options)
    job_run_key_result = execute_cli_with_param_list(self.class, "findJobResultKey",
                                                     [
                                                         options[:job_run_key]	# Handle associated with a particular job run
                                                     ])
    job_run_key = get_cli_return_value(job_run_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end
end