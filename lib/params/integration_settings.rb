class IntegrationSettings
  attr_reader :project_server
  attr_reader :project_server_id
  attr_reader :dns
  attr_reader :username
  attr_reader :password
  attr_reader :details

  def initialize(dns, username, password, details = nil, project_server = nil, project_server_id = nil)
    @dns = dns
    @username = username
    @password = password
    @details = details
    @project_server = project_server
    @project_server_id = project_server_id
  end

  def to_params
    params = {}
    params["SS_integration_dns"] = @dns
    params["SS_integration_username"] = @username
    params["SS_integration_password"] = @password
    params["SS_integration_details"] = @details

    params
  end
end
