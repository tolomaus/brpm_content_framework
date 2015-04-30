params = BrpmAuto.params
request_params = BrpmAuto.request_params

component_versions = request_params["component_versions"] || {}

component_versions[params["component"]] = params["component_version"]

BrpmAuto.log "Adding component version '#{params["component"]}' '#{params["component_version"]}' to the request_params..."
request_params["component_versions"] = component_versions

