require 'fileutils'
require "brpm_script_executor"

def setup_brpm_auto
  FileUtils.mkdir_p "/tmp/brpm_content"

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
