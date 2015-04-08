require "framework/lib/request_params"

def execute_script(params)
  request_params_manager = Framework::RequestParamsManager.new(params["SS_output_dir"])
  request_params = request_params_manager.get_request_params

  component_versions = request_params["component_versions"] || {}

  component_versions[params["component"]] = params["component_version"]

  Logger.log "Adding component version '#{params["component"]}' '#{params["component_version"]}' to the request_params..."
  request_params_manager.add_request_param("component_versions", component_versions)
end

