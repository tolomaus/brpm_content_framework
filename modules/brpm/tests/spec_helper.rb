require 'fileutils'
FileUtils.mkdir_p "/tmp/brpm_content/step_1"

require "#{File.dirname(__FILE__)}/../../framework/brpm_automation"
BrpmAuto.initialize_logger("/tmp/brpm_content/tests.log")
BrpmAuto.initialize_request_params("/tmp/brpm_content")

BrpmAuto.require_module "brpm"
BrpmRest.setup('http://brpm-content.pulsar-it.be:8088/brpm', ENV["BRPM_API_TOKEN"])

def get_default_params
  params = {}
  params['debug'] = 'true'
  params['SS_base_url'] = 'http://brpm-content.pulsar-it.be:8088/brpm'
  params['SS_api_token'] = ENV["BRPM_API_TOKEN"]

  params['SS_output_dir'] = "/tmp/brpm_content/step_1"

  params
end

def cleanup_request_data_file
  request_params_file = "/tmp/brpm_content/step_1/request_data.json"
  File.delete(file) if File.exist?(file)
end

def cleanup_requests_and_plans_for_app(app_name)
  app = BrpmRest.get_app_by_name(app_name)

  requests = BrpmRest.get_requests_by({ "app_id" => app["id"]})

  requests.each do |request|
    BrpmRest.delete_request(request["id"]) unless request.has_key?("request_template")
  end

  plan_template = BrpmRest.get_plan_template_by_name("#{app_name} Release Plan")

  plans = BrpmRest.get_plans_by({ "plan_template_id" => plan_template["id"]})
  plans.each do |plan|
    BrpmRest.cancel_plan(plan["id"])
    BrpmRest.delete_plan(plan["id"])
  end
end

def cleanup_version_tags_for_app(app_name)
  app = BrpmRest.get_app_by_name(app_name)

  version_tags = BrpmRest.get_version_tags_by({ "app_id" => app["id"]})

  version_tags.each do |version_tag|
    BrpmRest.delete_version_tag(version_tag["id"])
  end
end