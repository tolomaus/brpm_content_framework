require "framework/lib/request_params"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  if request_params.has_key?("instance_name")
    environment = request_params["instance_name"]
  else
    environment = params["SS_environment"]
  end

  BrpmAuto.log "Stopping the database container ..."
  stop_running_containers_if_necessary(["brpm_db_#{environment}"])
end