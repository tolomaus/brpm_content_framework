require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  Logger.log "Creating the installed component for DatabaseCreator ..."
  installed_component=create_installed_component("DatabaseCreator", "4.3.01.06", request_params["instance_name"], params["application"], get_docker_server_name())
end


