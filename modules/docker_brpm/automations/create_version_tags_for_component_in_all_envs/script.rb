brpm_rest_client = BrpmRestClient.new
params = BrpmAuto.params
request_params = BrpmAuto.request_params

BrpmAuto.log "Getting all environments of application #{params["application"]} ..."
environments = brpm_rest_client.get_environments_of_application(params["application"])

environments.each do |environment|
  BrpmAuto.log "Creating the version tag for version #{request_params["application_version"]} of application #{params["application"]} and component #{params["component"]} in environment #{environment["name"]} ..."
  environment = brpm_rest_client.create_version_tag(params["application"], params["component"], environment["name"], request_params["application_version"])
end


