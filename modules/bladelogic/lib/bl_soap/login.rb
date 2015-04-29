class Login < BsaSoapBase
  def initialize(integration_settings = BrpmAuto.integration_settings)
    @url = integration_settings.dns
    @username = integration_settings.username
    @password = integration_settings.password
    @role = integration_settings.details["role"]
  end

  def login
    login_with_role(@url, @username, @password, @role)
  end

  def login_with_credentials(url, username, password, auth_type = DEFAULT_AUTH_TYPE)
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
    session_id = login_with_credentials(url, username, password)
    assume_role(url, role, session_id)
    return session_id
  end
end