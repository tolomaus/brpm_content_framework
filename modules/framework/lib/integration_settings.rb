class IntegrationSettings
  attr_reader :dns
  attr_reader :username
  attr_reader :password
  attr_reader :details

  def initialize(dns, username, password, details)
    @dns = dns
    @username = username
    @password = password
    @details = details
  end
end
