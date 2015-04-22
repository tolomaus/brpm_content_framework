require "framework/lib/request_params"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  if request_params.has_key?("instance_name")
    environment = request_params["instance_name"]
  else
    environment = params["SS_environment"]
  end

  BrpmAuto.log "Stopping dependent docker containers if necessary ..."
  stop_running_containers_if_necessary(["brpm_#{environment}", "brpm_db_#{environment}"])

  BrpmAuto.log "Running the database container ..."
  run_docker_command("run -d --restart=always -v /home/ubuntu/docker_data/brpm_db_#{environment}:/var/lib/pgsql/data --name brpm_db_#{environment} bmc_devops/brpm_db:v1.0.0")
end