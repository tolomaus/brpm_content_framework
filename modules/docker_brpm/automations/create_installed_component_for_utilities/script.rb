require "framework/lib/request_params"
require "brpm/lib/brpm_rest_client"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  installed_component=create_installed_component("Application", "", request_params["instance_name"], params["application"], get_docker_server_name())
end


