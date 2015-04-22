require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  BrpmAuto.log "Creating the environment ..."
  environment = create_environment(request_params["instance_name"])

  BrpmAuto.log "Linking the environment to the docker host ..."
  link_environment_to_server(environment["id"], get_docker_server_name())

  BrpmAuto.log "Linking the environment to the app ..."
  link_environment_to_app(environment["id"], params["application"])
end


