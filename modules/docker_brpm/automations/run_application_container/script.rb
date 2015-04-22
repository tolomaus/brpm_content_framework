require "framework/lib/request_params"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  if request_params.has_key?("application_version")
    application_version = request_params["application_version"]
  else
    application_version = params["step_version"]
  end

  if request_params.has_key?("instance_name")
    environment = request_params["instance_name"]
  else
    environment = params["SS_environment"]
  end

  if request_params.has_key?("port")
    port = request_params["port"]
  else
    port = params["port"]
  end
  raise("No port specified.") if port.nil?

  BrpmAuto.log "Stopping dependent docker containers if necessary ..."
  stop_running_containers_if_necessary(["brpm_#{environment}"])

  BrpmAuto.log "Running the application container ..."
  run_docker_command("run -d --restart=always -p #{port}:8080 --link brpm_db_#{environment}:db --name brpm_#{environment} bmc_devops/brpm:v#{application_version}")
end