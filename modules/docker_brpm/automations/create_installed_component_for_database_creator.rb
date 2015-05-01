brpm_rest_client = BrpmRestClient.new
params = BrpmAuto.params
request_params = BrpmAuto.request_params

BrpmAuto.log "Creating the installed component for DatabaseCreator ..."
installed_component=brpm_rest_client.create_installed_component("DatabaseCreator", "4.3.01.06", request_params["instance_name"], params["application"], get_docker_server_name())


