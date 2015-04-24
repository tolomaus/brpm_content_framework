class IntegrationSettings
  private_class_method :new

  class << self
    attr_reader :dns
    attr_reader :username
    attr_reader :password
    attr_reader :details

    def setup(params)
      if params["SS_integration_dns"]
        @dns = params["SS_integration_dns"]
        @username = params["SS_integration_username"]
        @password = params["SS_integration_password"] || decrypt_string_with_prefix(params["SS_integration_password_enc"])
        @details = params["SS_integration_details"]
      end
    end
  end
end

IS = IntegrationSettings
