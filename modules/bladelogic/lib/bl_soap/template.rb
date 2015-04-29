class Template < BsaSoapBase
	def get_db_key_by_group_and_name(options = {})
    validate_cli_options_hash([:group_name, :parent_id], options)
		integer_result = execute_cli_with_param_list(self.class, "getDBKeyByGroupAndName",
			[
				options[:parent_group],
				options[:template_name]
			])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.class} function: #{exception.to_s}"
	end
end