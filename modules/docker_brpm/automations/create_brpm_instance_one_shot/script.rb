require "brpm/lib/brpm_rest_client"
require "docker_brpm/lib/docker"

def execute_script(params)
  application_version = params["application_version"]
  instance_name = params["instance_name"]
  app_name = params["application"]
  port = params["port"]
  docker_server_name = get_docker_server_name
  docker_host_name = get_docker_host_name

  BrpmAuto.log "Creating a BRPM instance named '#{instance_name}' on port #{port} (docker host = #{docker_host_name})..."
  BrpmAuto.log ""
  BrpmAuto.log ""

  BrpmAuto.log "Creating the environment ..."
  environment = create_environment(instance_name)

  BrpmAuto.log "Linking the environment to the docker host ..."
  link_environment_to_server(environment["id"], docker_server_name)

  BrpmAuto.log "Linking the environment to the app ..."
  link_environment_to_app(environment["id"], app_name)

  BrpmAuto.log "Creating the installed component for Utilities ..."
  create_installed_component("Database", "", instance_name, app_name, docker_server_name)

  BrpmAuto.log "Creating the database ..."
  run_docker_command("run --rm -e OVERWRITE_EXISTING_DATA=0 -v /home/ubuntu/docker_data/brpm_db_#{instance_name}:/data --name brpm_db_init_#{instance_name} bmc_devops/brpm_db_init:v4.3.01.06")

  BrpmAuto.log "Creating the installed component for DatabaseCreator ..."
  create_installed_component("DatabaseCreator", "4.3.01.06", instance_name, app_name, docker_server_name)

  BrpmAuto.log "Running the database container ..."
  run_docker_command("run -d --restart=always -v /home/ubuntu/docker_data/brpm_db_#{instance_name}:/var/lib/pgsql/data --name brpm_db_#{instance_name} bmc_devops/brpm_db:v1.0.0")

  BrpmAuto.log "Creating the installed component for Database ..."
  create_installed_component("Database", "1.0.0", instance_name, app_name, docker_server_name)

  BrpmAuto.log "Upgrading the database ..."
  run_docker_command("run --rm --link brpm_db_#{instance_name}:db bmc_devops/brpm:v#{application_version} /source-files/upgradedatabase.sh")

  BrpmAuto.log "Running the application container ..."
  run_docker_command("run -d --restart=always -p #{port}:8080 --link brpm_db_#{instance_name}:db --name brpm_#{instance_name} bmc_devops/brpm:v#{application_version}")

  BrpmAuto.log "Creating the installed component for Application ..."
  installed_component=create_installed_component("Application", application_version, instance_name, app_name, docker_server_name)

  BrpmAuto.log "Setting the port for Application ..."
  set_property_of_installed_component(installed_component["id"], "port", port)

  BrpmAuto.log "Finished"
  BrpmAuto.log ""
  BrpmAuto.log "You can now access the newly created instance on http://#{docker_host_name}:#{port}/brpm"
  BrpmAuto.log ""
  BrpmAuto.log ""

  BrpmAuto.log "Currently running containers:"
  run_docker_command("ps")
end


