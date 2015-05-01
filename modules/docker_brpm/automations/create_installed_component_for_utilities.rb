brpm_rest_client = BrpmRestClient.new
params = BrpmAuto.params
request_params = BrpmAuto.request_params

installed_component=brpm_rest_client.create_installed_component("Application", "", request_params["instance_name"], params["application"], get_docker_server_name())


