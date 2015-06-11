require 'json'
require 'uri'

class TeamcityRestClient
  def initialize(integration_settings = BrpmAuto.integration_settings)
    @url = integration_settings.dns
    @username = integration_settings.username
    @password = integration_settings.password

    @api_url = "#{@url}/rest/api"
  end

  def trigger_build(application, component)
    data = {:application => application, :component => component}
    Rest.post("#{@api_url}/build", data)["response"]
  end
end
