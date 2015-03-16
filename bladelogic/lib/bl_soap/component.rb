require "bladelogic/lib/bl_soap/soap"

module BsaComponent
	extend BsaSoap
end

class Template
	def self.get_db_key_by_group_and_name(url, session_id, options = {})
    BsaComponent.validate_cli_options_hash([:group_name, :parent_id], options)
		integer_result = BsaComponent.execute_cli_with_param_list(url, session_id, self.name, "getDBKeyByGroupAndName",
			[
				options[:parent_group],
				options[:template_name]
			])
		integer_value = BsaComponent.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
end