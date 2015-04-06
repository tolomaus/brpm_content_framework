require "#{File.dirname(__FILE__)}/../../framework/bootstrap"
require 'fileutils'

Dir.mkdir_p "/tmp/brpm_content/"
Logger.initialize({ "log_file" => "/tmp/brpm_content/tests.log" }) # TODO clean up

require "brpm/lib/brpm_rest_api"
require "framework/lib/request_params"

def get_default_params
  params = {}
  params['SS_base_url'] = 'http://brpm-content.pulsar-it.be:8088/brpm' # TODO "http://#{ENV["BRPM_HOST"]}:#{ENV["BRPM_PORT"]}/brpm"
  params['SS_api_token'] = ENV["BRPM_API_TOKEN"]

  dir = "/tmp/brpm_content/step_1"
  params['SS_output_dir'] = dir # TODO clean up

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