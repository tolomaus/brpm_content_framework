require 'savon'

#
# Module: BsaSoap
# Description:
# 	Provides base soap services including:
#	* login
#	* role assumption
#	* CLI execution with attachment
#	* CLI execution with parameter list
#   * logging management (ability to disable logging from Savon and HTTPI)
# 
# TODO:
# * test commands with no args
#
module BsaSoap
	# Filter out password data when logging enabled
	Savon.configure do |config|
		config._logger.filter << :password
	end

	# Module Constants
	HTTP_READ_TIMEOUT = 300
	DEFAULT_AUTH_TYPE = "SRP"
	LOGIN_WSDL        = "/services/BSALoginService.wsdl"
	ROLE_WSDL         = "/services/BSAAssumeRoleService.wsdl"
	CLI_WSDL          = "/services/BSACLITunnelService.wsdl"
	LOGIN_SERVICE     = "/services/LoginService"
	ROLE_SERVICE      = "/services/AssumeRoleService"
	CLI_SERVICE       = "/services/CLITunnelService"
	
	extend self
	def disable_verbose_logging
		HTTPI.log = false
		Savon.configure do |config|
			config.log = false
		end
	end
	
	def login(url, username, password, auth_type = DEFAULT_AUTH_TYPE)
		client = Savon.client("#{url}#{LOGIN_WSDL}") do |wsdl, http|
			http.auth.ssl.verify_mode = :none
		end
		response = client.request(:login_using_user_credential) do |soap|
			soap.endpoint = "#{url}#{LOGIN_SERVICE}"
			soap.body = {:userName => username, :password => password, :authenticationType => auth_type}
		end
		session_id = response.body[:login_using_user_credential_response][:return_session_id]
	rescue Savon::Error => error
		raise "Error while attempting BSA login,ensure connectivity and BSA Integration properties: #{error.to_s}"
	end
	
	def assume_role(url, role, session_id, http_timeout = HTTP_READ_TIMEOUT)
		client = Savon.client("#{url}#{ROLE_WSDL}") do |wsdl, http|
			http.auth.ssl.verify_mode = :none
		end
		client.http.read_timeout = http_timeout
		response = client.request(:assume_role) do |soap|
			soap.endpoint = "#{url}#{ROLE_SERVICE}"
			soap.header = {"ins0:sessionId" => session_id}
			soap.body = { :roleName => role }
		end
	rescue Savon::Error => error
		raise "Error while acquiring BSA role(#{role}), ensure connectivity and BSA Integration properties: #{error.to_s}"
  end
	
	def login_with_role(url, username, password, role)
		session_id = login(url, username, password)
		assume_role(url, role, session_id)
		return session_id
	end
	
	def validate_cli_options_hash(required_keys, options)
		required_keys.each { |key| raise "Invalid options hash(missing #{key}) for command, cannot continue" unless options.has_key?(key) }
	end
	
	def validate_cli_option_hash_string_values(supported_values, options_key)
		supported_values.any? {
			|value| raise "options key value(#{options_value}) not supported" unless options_key.eql?(value)
		}
	end
	
	def get_all_servers(url, session_id, server_group)
		result = execute_cli_with_param_list(url, session_id, "Server", "listServersInGroup", [server_group])
		servers = get_cli_return_value(result)
	rescue => exception
		raise "Failed to get all servers for #{server_group}: #{exception.to_s}"
	end
	
	def validate_servers(url, session_id, servers = [])
		error = {}
		servers.each do |server|
			result = execute_cli_with_param_list(url, session_id, "Server", "printPropertyValue", [server, "AGENT_STATUS"])
			if result[:success] == false || result[:return_value] != "agent is alive"
				error[:"#{server}"] = "cannot validate server status"
			end
		end
		if error.length > 0
			raise "Problem validating server: #{error}"
		end
	rescue => exception
		raise "Failed to validate server: #{exception.to_s}"
	end
	
	def validate_cli_result(result)
      if result && (result.is_a? Hash)
        if result[:success] == false
          raise "Command execution failed: #{result[:error]}, #{result[:comments]}"
        end
        return result
      else
        raise "Command execution did not return a valid response: #{result.inspect}"
      end
      nil
    end
	
	def get_cli_return_value(result)
		if result && result.is_a?(Hash) && result.has_key?(:success) && result[:success]
			return result[:return_value]
		end
		nil
	end
	
	def execute_cli_with_attachments(url, session_id, namespace, command, args, payload)
		Logger.log("blcli #{namespace} #{command} #{args.join(" ")}")

    client = Savon.client("#{url}#{CLI_WSDL}") do |wsdl, http|
			http.auth.ssl.verify_mode = :none
		end
		client.http.read_timeout = HTTP_READ_TIMEOUT
		response = client.request(:execute_command_using_attachments) do |soap|
			soap.endpoint = "#{url}#{CLI_SERVICE}"
			soap.header = {"ins1:sessionId" => session_id}
			body_details = { :nameSpace => namespace, :commandName => command, :commandArguments => args }
			body_details.merge!({:payload => payload}) if payload
			soap.body = body_details
		end
		result = response.body[:execute_command_using_attachments_response][:return]
		return validate_cli_result(result)
	rescue Savon::Error => error
		raise "Error while executing CLI command over SOAP protocol: #{error.to_s}"
	rescue => exception
		raise "Error processing CLI(#{namespace}:#{command}) result: #{exception.to_s}"
  end

  def execute_cli_with_param_list(url, session_id, namespace, command, args = [])
    Logger.log("blcli #{namespace} #{command} #{args.join(" ")}")

		client = Savon.client("#{url}#{CLI_WSDL}") do |wsdl, http|
			http.auth.ssl.verify_mode = :none
		end
		client.http.read_timeout = HTTP_READ_TIMEOUT
		response = client.request(:execute_command_by_param_list) do |soap|
			soap.endpoint = "#{url}#{CLI_SERVICE}"
			soap.header = {"ins1:sessionId" => session_id}
			soap.body = { :nameSpace => namespace, :commandName => command, :commandArguments => args }
		end
		result = response.body[:execute_command_by_param_list_response][:return]
		return validate_cli_result(result)
	rescue Savon::Error => error
		raise "Error while executing CLI command over SOAP protocol: #{error.to_s}"
	rescue Exception => exception
		raise "Error processing CLI(#{namespace}:#{command}) results: #{exception.to_s}"
  end
end