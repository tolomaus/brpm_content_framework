params = BrpmAuto.params

component_versions = BrpmAuto.request_params["component_versions"] || {}

component_versions[params["component"]] = params["component_version"] unless BrpmAuto.request_params["auto_created"]

BrpmAuto.log "Adding component version '#{params["component"]}' '#{params["component_version"]}' to the request_params..."
BrpmAuto.request_params["component_versions"] = component_versions

