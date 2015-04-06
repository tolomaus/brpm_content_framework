require "brpm/lib/brpm_rest_api"
require "atrium_orchestrator/lib/ao_soap_api"

def execute_script(params)
  workflow = params["workflow_list"].index(params["workflow"].strip)

  server_group = "/#{get_server_group_from_step_id(params["step_id"])}"

  Logger.log("Setting up the AO connection parameters ...")
  set_ao_soap_api_url(params["SS_integration_dns"])
  set_ao_soap_api_username(params["SS_integration_username"])
  set_ao_soap_api_password(decrypt_string_with_prefix(params["SS_integration_password_enc"]))
  set_ao_soap_api_grid_name(params["grid_name"])
  set_ao_soap_api_module_name(params["module_name"])

  Logger.log("Executing workflow #{workflow} in AO ...")
  ao_execute_workflow("#{params["application"].downcase}-#{workflow}", { "server_group" => server_group })
  Logger.log("Done.")

end