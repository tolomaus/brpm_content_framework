require "framework/lib/request_params"
require "brpm/lib/brpm_rest_client"

def execute_script(params)
  request_params = get_request_params()

  BrpmAuto.log "Getting all environments of application #{params["application"]} ..."
  environments = get_environments_of_application(params["application"])

  environments.each do |environment|
    BrpmAuto.log "Creating the version tag for version #{request_params["application_version"]} of application #{params["application"]} and component #{params["component"]} in environment #{environment["name"]} ..."
    environment = create_version_tag(params["application"], params["component"], environment["name"], request_params["application_version"])
  end
end


