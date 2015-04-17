require "bladelogic/lib/bl_soap/soap"

class Server
	def self.get_server_id_by_name(ession_id, options = {})
    BsaSoap.validate_cli_options_hash([:server_name], options)
		integer_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "getServerIdByName",
			[
				options[:server_name],
			])
		integer_value = BsaSoap.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
end