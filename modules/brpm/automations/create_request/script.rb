require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"

def execute_script(params)
  request_params_manager = Framework::RequestParamsManager.new(params["SS_output_dir"])
  request_params = request_params_manager.get_request_params

  brpm_client = Brpm::Client.new(params["SS_base_url"], params["SS_api_token"])

  Logger.log "Retrieving the application..."
  application = brpm_client.get_app_by_name(params["application"])
  application_version = request_params["application_version"] || ""

  Logger.log "Retrieving the environment..."
  target_environment = brpm_client.get_environment_by_id(params["target_environment_id"])

  if request_params.has_key? "request_template_id"
    request_template_id = request_params["request_template_id"]
    request_template_name = nil
  else
    request_template_id = nil
    request_template_name = "Deploy #{application["name"]}"
  end

  Logger.log "Creating request 'Deploy #{application["name"]} #{application_version}' from template '#{request_template_id || request_template_name}' for application '#{application["name"]}' and environment '#{target_environment["name"]}'..."
  request = {}
  request["request_template_id"] = request_template_id
  request["template_name"] = request_template_name
  request["name"] = "Deploy #{application["name"]} #{application_version}"
  request["environment"] = target_environment["name"]
  request["execute_now"] = false
  request["app_ids"] = [application["id"]]
  target_request = brpm_client.create_request_from_hash(request)

  unless target_request["apps"].first["id"] == application["id"]
    Logger.log "The application from the template is different than the application we want to use so updating the request with the correct application..."
    request = {}
    request["id"] = target_request["id"]
    request["app_ids"] = [application["id"]]
    target_request = brpm_client.update_request_from_hash(request)
  end

  if request_params.has_key?"component_versions"
    Logger.log "Component versions found in the request params so setting the version number of the components... "
    request_params["component_versions"].each do |component_name, component_version|
      Logger.log "Setting the version of component '#{component_name}' to '#{component_version}'... "
      brpm_client.set_version_tag_of_steps_for_component(target_request, component_name, component_version)
    end
  elsif ! application_version.empty?
    Logger.log "Application version found so setting the version number of all components to #{application_version}... "
    application["components"].each do |component|
      brpm_client.set_version_tag_of_steps_for_component(target_request, component["name"], application_version)
    end
  end

  if params["execute_target_request"].downcase.include?("execute")
    Logger.log "Planning the request ... "
    brpm_client.plan_request(target_request["id"])

    Logger.log "Starting the request ... "
    brpm_client.start_request(target_request["id"])
  end

  if params["execute_target_request"].downcase.include?("monitor")
    Logger.log "Waiting until the request has finished ..."
    brpm_client.monitor_request(target_request["id"])
  end

  Logger.log "Adding the created request' id to the request_params ..."
  request_params_manager.add_request_param("target_request_id", target_request["id"])
end

