require "bladelogic/lib/bl_soap/soap"

module BsaServer
	extend BsaSoap
end

class Server
	def self.get_server_id_by_name(url, session_id, options = {})
    BsaComponent.validate_cli_options_hash([:server_name], options)
		integer_result = BsaComponent.execute_cli_with_param_list(url, session_id, self.name, "getServerIdByName",
			[
				options[:server_name],
			])
		integer_value = BsaComponent.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
end