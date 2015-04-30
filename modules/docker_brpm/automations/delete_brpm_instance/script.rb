brpm_rest_client = BrpmRestClient.new
params = BrpmAuto.params

BrpmAuto.log "Deleting BRPM instance named '#{params["instance_name"]}' (docker host = #{get_docker_host_name()})..."
BrpmAuto.log ""
BrpmAuto.log ""

BrpmAuto.log "Unlinking the environment from the app ..."
brpm_rest_client.unlink_environment_from_app(params["instance_name"], params["application"])

BrpmAuto.log "Unlinking the environment from the server ..."
brpm_rest_client.unlink_environment_from_server(params["instance_name"], get_docker_server_name())

BrpmAuto.log "Deleting the environment ..."
brpm_rest_client.delete_environment(params["instance_name"])

BrpmAuto.log "Stopping the application container ..."
run_docker_command_and_ignore_error("stop brpm_#{params["instance_name"]}")

BrpmAuto.log "Deleting the application container ..."
run_docker_command_and_ignore_error("rm brpm_#{params["instance_name"]}")

BrpmAuto.log "Stopping the database container ..."
run_docker_command_and_ignore_error("stop brpm_db_#{params["instance_name"]}")

BrpmAuto.log "Deleting the database container ..."
run_docker_command_and_ignore_error("rm brpm_db_#{params["instance_name"]}")

BrpmAuto.log "The data directory located at /home/ubuntu/docker_data/brpm_db_#{params["instance_name"]} must be deleted manually."

BrpmAuto.log "Finished"
BrpmAuto.log ""
BrpmAuto.log ""

BrpmAuto.log "Currently running containers:"
run_docker_command("ps")


