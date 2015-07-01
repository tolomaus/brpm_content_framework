class Server < BsaSoapBase
	def get_server_id_by_name(ession_id, options = {})
    validate_cli_options_hash([:server_name], options)
		integer_result = execute_cli_with_param_list(self.class, "getServerIdByName",
			[
				options[:server_name],
			])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.class} function: #{exception.to_s}"
	end
end