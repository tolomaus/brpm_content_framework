require "framework/lib/request_params"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  if request_params.has_key?("instance_name")
    environment = request_params["instance_name"]
  else
    environment = params["SS_environment"]
  end

  if params.has_key?("overwrite_existing_data") && !params["overwrite_existing_data"].nil?
    overwrite_existing_data = params["overwrite_existing_data"]
  elsif request_params.has_key?("overwrite_existing_data")
    overwrite_existing_data = request_params["overwrite_existing_data"]
  else
    overwrite_existing_data = "0"
  end

  BrpmAuto.log "Stopping dependent docker containers if necessary ..."
  stop_running_containers_if_necessary(["/brpm_#{environment}", "/brpm_db_#{environment}"])

  BrpmAuto.log "Creating the database ..."
  run_docker_command("run --rm -e OVERWRITE_EXISTING_DATA=#{overwrite_existing_data} -v /home/ubuntu/docker_data/brpm_db_#{environment}:/data --name brpm_db_init_#{environment} bmc_devops/brpm_db_init:v4.3.01.06")
end


