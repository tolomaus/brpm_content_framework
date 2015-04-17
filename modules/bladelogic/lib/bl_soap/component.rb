require "bladelogic/lib/bl_soap/soap"

class Template
	def self.get_db_key_by_group_and_name(session_id, options = {})
    BsaSoap.validate_cli_options_hash([:group_name, :parent_id], options)
		integer_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "getDBKeyByGroupAndName",
			[
				options[:parent_group],
				options[:template_name]
			])
		integer_value = BsaSoap.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
end