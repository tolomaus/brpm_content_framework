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

  BrpmAuto.log "Upgrading the database ..."
  run_docker_command("run --rm --link brpm_db_#{environment}:db bmc_devops/brpm:v#{application_version} /source-files/upgradedatabase.sh")
end


