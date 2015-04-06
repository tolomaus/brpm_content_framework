require "#{File.dirname(__FILE__)}/../modules/framework/bootstrap"

Logger.initialize({ "log_file" => "/home/jenkins/logs/test.log" })

require "brpm/lib/brpm_rest_api"

def configure_brpm_rest_api
  set_brpm_rest_api_url("http://#{ENV["BRPM_HOST"]}:#{ENV["BRPM_PORT"]}/brpm")
  set_brpm_rest_api_token(ENV["BRPM_API_TOKEN"])
end

ADMIN_USER_ID = 1
SMARTRELEASE_APP_ID = 1
