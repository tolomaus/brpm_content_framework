require 'savon'

class BsaSoapBase
  # Filter out password data when logging enabled
  HTTPI.log = false
  Savon.configure do |config|
    config._logger.filter << :password
    config.log = false
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

  def initialize(url, session_id)
    @url = url
    @session_id = session_id
  end

  def validate_cli_options_hash(required_keys, options)
    required_keys.each { |key| raise "Invalid options hash(missing #{key}) for command, cannot continue" unless options.has_key?(key) }
  end

  def validate_cli_option_hash_string_values(supported_values, options_key)
    supported_values.any? {
      |value| raise "options key value(#{options_value}) not supported" unless options_key.eql?(value)
    }
  end

  def get_all_servers(server_group)
    result = execute_cli_with_param_list("Server", "listServersInGroup", [server_group])
    servers = get_cli_return_value(result)
  rescue => exception
    raise "Failed to get all servers for #{server_group}: #{exception.to_s}"
  end

  def validate_servers(servers = [])
    error = {}
    servers.each do |server|
      result = execute_cli_with_param_list("Server", "printPropertyValue", [server, "AGENT_STATUS"])
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

  def execute_cli_with_attachments(namespace, command, args, payload)
    BrpmAuto.log("blcli #{namespace} #{command} #{args.join(" ")}")

    client = Savon.client("#{@url}#{CLI_WSDL}") do |wsdl, http|
      http.auth.ssl.verify_mode = :none
    end
    client.http.read_timeout = HTTP_READ_TIMEOUT
    response = client.request(:execute_command_using_attachments) do |soap|
      soap.endpoint = "#{@url}#{CLI_SERVICE}"
      soap.header = {"ins1:sessionId" => @session_id}
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

  def execute_cli_with_param_list(namespace, command, args = [])
    BrpmAuto.log("blcli #{namespace} #{command} #{args.join(" ")}")

    client = Savon.client("#{@url}#{CLI_WSDL}") do |wsdl, http|
      http.auth.ssl.verify_mode = :none
    end
    client.http.read_timeout = HTTP_READ_TIMEOUT
    response = client.request(:execute_command_by_param_list) do |soap|
      soap.endpoint = "#{@url}#{CLI_SERVICE}"
      soap.header = {"ins1:sessionId" => @session_id}
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