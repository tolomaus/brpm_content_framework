brpm_rest_client = BrpmRestClient.new
params = BrpmAuto.params
request_params = BrpmAuto.request_params

BrpmAuto.log "Creating the environment ..."
environment = brpm_rest_client.create_environment(request_params["instance_name"])

BrpmAuto.log "Linking the environment to the docker host ..."
brpm_rest_client.link_environment_to_server(environment["id"], get_docker_server_name())

BrpmAuto.log "Linking the environment to the app ..."
brpm_rest_client.link_environment_to_app(environment["id"], params["application"])


