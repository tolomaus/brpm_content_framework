require 'fileutils'
require "#{File.dirname(__FILE__)}/../../framework/brpm_script_executor"

def setup_brpm_auto
  FileUtils.mkdir_p "/tmp/brpm_content"

  BrpmAuto.setup( { "output_dir" => "/tmp/brpm_content" }.merge!(get_integration_params_for_jira) )

  BrpmAuto.require_module "brpm"
  BrpmAuto.require_module "teamcity"

  @teamcity_rest_client = TeamcityRestClient.new
end

def get_default_params
  params = {}
  params['also_log_to_console'] = 'true'

  params['brpm_url'] = 'http://brpm-content.pulsar-it.be:8088/brpm'
  params['brpm_api_token'] = ENV["BRPM_API_TOKEN"]

  params['output_dir'] = "/tmp/brpm_content"

  params
end

def get_integration_params_for_teamcity
  params = {}
  params["SS_integration_dns"] = 'http://brpm.pulsar-it.be:6060'
  params["SS_integration_username"] = 'brpm'
  params["SS_integration_password"] = ENV["TEAMCITY_PASSWORD"]

  params
end
