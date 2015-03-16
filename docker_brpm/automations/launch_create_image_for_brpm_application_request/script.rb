require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"

def execute_script(params)
  request_params = get_request_params()

  new_request_params = {}
  new_request_params["calling_request"] = params["SS_request_number"]
  new_request_params["application_version"] = request_params["application_version"]

  Logger.log "Creating a new request from template 'Create image for BRPM' for BRPM v#{request_params["application_version"]} ..."
  new_request = create_request_for_plan_from_template(
      params["request_plan_id"].to_i,
      "Packaging",
      "Create image for BRPM",
      "Create image for BRPM v#{request_params["application_version"]}",
      "[default]",
      false, #execute_now
      new_request_params
  )

  Logger.log "Planning the request ... "
  plan_request(new_request["id"])

  Logger.log "Starting the request ... "
  start_request(new_request["id"])

  Logger.log "Waiting until the request has finished ..."
  monitor_request(new_request["id"], { :max_time => params["max_time"], :checking_interval => params["checking_interval"] })
end