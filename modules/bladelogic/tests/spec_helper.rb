require "#{File.dirname(__FILE__)}/../../framework/bootstrap"
require 'fileutils'

FileUtils.mkdir_p "/tmp/brpm_content/"
Logger.initialize({ "log_file" => "/tmp/brpm_content/tests.log" }) # TODO clean up

require "brpm/lib/brpm_rest_api"
require "framework/lib/request_params"

def get_default_params
  params = {}
  params['debug'] = 'true'
  params['SS_base_url'] = 'http://brpm-content.pulsar-it.be:8088/brpm'
  params['SS_api_token'] = ENV["BRPM_API_TOKEN"]

  dir = "/tmp/brpm_content/step_1"
  params['SS_output_dir'] = dir # TODO clean up

  params
end

def get_integration_settings_for_bladelogic
  params = {}
  params["SS_integration_dns"] = "https://bladelogic.pulsar-it.be:9843"
  params["SS_integration_username"] = "BLAdmin"
  params["SS_integration_password"] = ENV["BLADELOGIC_PASSWORD"]
  params["SS_integration_details"] = {}
  params["SS_integration_details"]["role"] = "BLAdmins"

  params
end

def get_brpm_client
  params = get_default_params
  Brpm::Client.new(params["SS_base_url"], params["SS_api_token"])
end

def get_request_params_manager
  params = get_default_params
  Framework::RequestParamsManager.new(params["SS_output_dir"])
end

def cleanup_request_data_file
  file = get_request_params_manager.get_request_params_file_location
  File.delete(file) if File.exist?(file) # TODO clean up
end

def cleanup_requests_and_plans_for_app(app_name)
  brpm_client = get_brpm_client

  app = brpm_client.get_app_by_name(app_name)

  requests = brpm_client.get_requests_by({ "app_id" => app["id"]})

  requests.each do |request|
    brpm_client.delete_request(request["id"]) unless request.has_key?("request_template")
  end

  plan_template = brpm_client.get_plan_template_by_name("#{app_name} Release Plan")

  plans = brpm_client.get_plans_by({ "plan_template_id" => plan_template["id"]})
  plans.each do |plan|
    brpm_client.cancel_plan(plan["id"])
    brpm_client.delete_plan(plan["id"])
  end
end

def cleanup_version_tags_for_app(app_name)
  brpm_client = get_brpm_client

  app = brpm_client.get_app_by_name(app_name)

  version_tags = brpm_client.get_version_tags_by({ "app_id" => app["id"]})

  version_tags.each do |version_tag|
    brpm_client.delete_version_tag(version_tag["id"])
  end
end

def pack_response
end