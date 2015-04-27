require 'fileutils'
FileUtils.mkdir_p "/tmp/brpm_content/step_1"

require "#{File.dirname(__FILE__)}/../../framework/brpm_automation"
BrpmAuto.initialize_logger("/tmp/brpm_content/tests.log")
BrpmAuto.initialize_request_params("/tmp/brpm_content")

BrpmAuto.require_module "brpm"
BrpmRest.setup('http://brpm-content.pulsar-it.be:8088/brpm', ENV["BRPM_API_TOKEN"])

BrpmAuto.require_module "jira"
JiraRest.setup('http://brpm.pulsar-it.be:9090', 'brpm', ENV["JIRA_PASSWORD"])

def get_default_params
  params = {}
  params['debug'] = 'true'
  params['SS_base_url'] = 'http://brpm-content.pulsar-it.be:8088/brpm'
  params['SS_api_token'] = ENV["BRPM_API_TOKEN"]

  params['SS_output_dir'] = "/tmp/brpm_content/step_1"

  params
end

def get_integration_details_for_jira
  params = {}
  params["SS_integration_dns"] = 'http://brpm.pulsar-it.be:9090'
  params["SS_integration_username"] = 'brpm'
  params["SS_integration_password"] = ENV["JIRA_PASSWORD"]

  params["jira_release_field_id"] = '10000'

  params
end

def cleanup_request_data_file
  request_params_file = "/tmp/brpm_content/step_1/request_data.json"
  File.delete(file) if File.exist?(file)
end

def cleanup_release(release_name)
  JiraRest.delete_option_for_dropdown_custom_field('10000', release_name)
end