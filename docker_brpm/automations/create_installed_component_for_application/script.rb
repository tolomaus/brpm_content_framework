require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  Logger.log "Creating the installed component for Application ..."
  installed_component=create_installed_component("Application", request_params["application_version"], request_params["instance_name"], params["application"], get_docker_server_name())

  Logger.log "Setting the port for Application ..."
  set_property_of_installed_component(installed_component["id"], "port", request_params["port"])
end


