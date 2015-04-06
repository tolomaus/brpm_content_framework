require "brpm/lib/brpm_rest_api"
require "framework/lib/request_params"

def execute_script(params)
  request_params = get_request_params

  if request_params["auto_created"]
    Logger.log "The request was created in an automated way, not overriding the request params from the manual input step."
    application_version = request_params["application_version"]
  else
    Logger.log "Storing the input parameters ..."
    add_request_param("application_version", params["application_version"])
    application_version = params["application_version"]
  end

  Logger.log "Creating version tags for all components..."
  application = get_app_by_name(params["application"])

  application["components"].each do |component|
    application["environments"].each do |environment|
      create_version_tag(application["name"], component["name"], environment["name"], application_version)
    end
  end
end


