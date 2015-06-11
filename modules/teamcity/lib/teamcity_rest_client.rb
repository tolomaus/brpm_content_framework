require 'json'
require 'uri'

#=============================================================================#
# Jira Rest Module                                                            #
#-----------------------------------------------------------------------------#
# The REST module currently supports the 6.0.8 version of the Jira API as     #
# well as a rest client which supports both HTTP and HTTPS                    #
#=============================================================================#

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
