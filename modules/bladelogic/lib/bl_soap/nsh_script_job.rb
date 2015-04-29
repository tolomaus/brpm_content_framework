# very basic support right now
class NSHScriptJob < BsaSoapBase
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
end
