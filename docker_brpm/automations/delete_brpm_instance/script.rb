require "brpm/lib/brpm_rest_api"
require "docker_brpm/lib/docker"

def execute_script(params)
  Logger.log "Deleting BRPM instance named '#{params["instance_name"]}' (docker host = #{get_docker_host_name()})..."
  Logger.log ""
  Logger.log ""

  Logger.log "Unlinking the environment from the app ..."
  unlink_environment_from_app(params["instance_name"], params["application"])

  Logger.log "Unlinking the environment from the server ..."
  unlink_environment_from_server(params["instance_name"], get_docker_server_name())

  Logger.log "Deleting the environment ..."
  delete_environment(params["instance_name"])

  Logger.log "Stopping the application container ..."
  run_docker_command_and_ignore_error("stop brpm_#{params["instance_name"]}")

  Logger.log "Deleting the application container ..."
  run_docker_command_and_ignore_error("rm brpm_#{params["instance_name"]}")

  Logger.log "Stopping the database container ..."
  run_docker_command_and_ignore_error("stop brpm_db_#{params["instance_name"]}")

  Logger.log "Deleting the database container ..."
  run_docker_command_and_ignore_error("rm brpm_db_#{params["instance_name"]}")

  Logger.log "The data directory located at /home/ubuntu/docker_data/brpm_db_#{params["instance_name"]} must be deleted manually."

  Logger.log "Finished"
  Logger.log ""
  Logger.log ""

  Logger.log "Currently running containers:"
  run_docker_command("ps")
end


