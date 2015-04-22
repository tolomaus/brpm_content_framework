def execute_script(params)
  request_params = RequestParams.get_request_params

  component_versions = request_params["component_versions"] || {}

  component_versions[params["component"]] = params["component_version"]

  BrpmAuto.log "Adding component version '#{params["component"]}' '#{params["component_version"]}' to the request_params..."
  RequestParams.add_request_param("component_versions", component_versions)
end

