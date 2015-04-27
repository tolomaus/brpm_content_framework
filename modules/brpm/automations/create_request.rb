def execute_script(params)
  request_params = BrpmAuto.request_params

  BrpmAuto.log "Retrieving the application..."
  application = BrpmRest.get_app_by_name(params["application"])
  application_version = request_params["application_version"] || ""

  BrpmAuto.log "Retrieving the environment..."
  target_environment = BrpmRest.get_environment_by_id(params["target_environment_id"])

  if request_params.has_key? "request_template_id"
    request_template_id = request_params["request_template_id"]
    request_template_name = nil
  else
    request_template_id = nil
    request_template_name = "Deploy #{application["name"]}"
  end

  BrpmAuto.log "Creating request 'Deploy #{application["name"]} #{application_version}' from template '#{request_template_id || request_template_name}' for application '#{application["name"]}' and environment '#{target_environment["name"]}'..."
  request = {}
  request["request_template_id"] = request_template_id
  request["template_name"] = request_template_name
  request["name"] = "Deploy #{application["name"]} #{application_version}"
  request["environment"] = target_environment["name"]
  request["execute_now"] = false
  request["app_ids"] = [application["id"]]
  target_request = BrpmRest.create_request_from_hash(request)

  unless target_request["apps"].first["id"] == application["id"]
    BrpmAuto.log "The application from the template is different than the application we want to use so updating the request with the correct application..."
    request = {}
    request["id"] = target_request["id"]
    request["app_ids"] = [application["id"]]
    target_request = BrpmRest.update_request_from_hash(request)
  end

  if request_params.has_key?"component_versions"
    BrpmAuto.log "Component versions found in the request params so setting the version number of the components... "
    request_params["component_versions"].each do |component_name, component_version|
      BrpmAuto.log "Setting the version of component '#{component_name}' to '#{component_version}'... "
      BrpmRest.set_version_tag_of_steps_for_component(target_request, component_name, component_version)
    end
  elsif ! application_version.empty?
    BrpmAuto.log "Application version found so setting the version number of all components to #{application_version}... "
    application["components"].each do |component|
      BrpmRest.set_version_tag_of_steps_for_component(target_request, component["name"], application_version)
    end
  end

  if params["execute_target_request"].downcase.include?("execute")
    BrpmAuto.log "Planning the request ... "
    BrpmRest.plan_request(target_request["id"])

    BrpmAuto.log "Starting the request ... "
    BrpmRest.start_request(target_request["id"])
  end

  if params["execute_target_request"].downcase.include?("monitor")
    BrpmAuto.log "Waiting until the request has finished ..."
    BrpmRest.monitor_request(target_request["id"])
  end

  BrpmAuto.log "Adding the created request' id to the request_params ..."
  request_params["target_request_id"] = target_request["id"]
end

