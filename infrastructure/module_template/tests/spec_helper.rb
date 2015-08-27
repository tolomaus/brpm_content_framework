require 'fileutils'
require "brpm_script_executor"

def setup_brpm_auto
  FileUtils.mkdir_p "/tmp/brpm_content"
  create_symlink_to_gemset

  BrpmAuto.setup( get_default_params.merge!(get_integration_params) )
end

def get_default_params
  params = {}
  params['also_log_to_console'] = 'true'

  params['brpm_url'] = ""
  params['brpm_api_token'] = ""

  params['output_dir'] = "/tmp/brpm_content"

  params
end

def get_integration_params
  params = {}
  params["SS_integration_dns"] = ""
  params["SS_integration_username"] = ""
  params["SS_integration_password"] = ""
  params["SS_integration_details"] = ""

  params
end

def create_symlink_to_gemset
  module_name = File.basename(File.expand_path("#{File.dirname(__FILE__)}/.."))
  symlink = "#{ENV["GEM_HOME"]}/gems/#{module_name}-999.0.0"
  FileUtils.rm(symlink) if File.exists?(symlink)
  FileUtils.ln_s(File.expand_path("#{File.dirname(__FILE__)}/.."), symlink)
end