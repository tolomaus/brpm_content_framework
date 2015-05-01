brpm_rest_client = BrpmRestClient.new
params = BrpmAuto.params
request_params = BrpmAuto.request_params

BrpmAuto.log "Creating the installed component for Application ..."
installed_component=brpm_rest_client.create_installed_component("Application", request_params["application_version"], request_params["instance_name"], params["application"], get_docker_server_name())

BrpmAuto.log "Setting the port for Application ..."
brpm_rest_client.set_property_of_installed_component(installed_component["id"], "port", request_params["port"])


