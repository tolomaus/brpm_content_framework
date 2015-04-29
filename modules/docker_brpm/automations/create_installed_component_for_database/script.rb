require "framework/lib/request_params"
require "brpm/lib/brpm_rest_client"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  create_installed_component("Database", "1.0.0", request_params["instance_name"], params["application"], get_docker_server_name())
end


