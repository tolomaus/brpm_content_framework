require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"

def execute_script(params)
  request_params = get_request_params()

  Logger.log "Getting the request ..."
  request = get_request_by_id(request_params["promoted_request_id"])

  Logger.log "Waiting until the request has finished ..."
  monitor_request(request["id"], { :max_time => 60 * 24})
end

