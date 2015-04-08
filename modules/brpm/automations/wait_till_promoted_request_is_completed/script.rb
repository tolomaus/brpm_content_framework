require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"

def execute_script(params)
  request_params_manager = Framework::RequestParamsManager.new(params["SS_output_dir"])
  request_params = request_params_manager.get_request_params()

  brpm_client = Brpm::Client.new(params["SS_base_url"], params["SS_api_token"])

  Logger.log "Getting the request ..."
  request = brpm_client.get_request_by_id(request_params["promoted_request_id"])

  Logger.log "Waiting until the request has finished ..."
  brpm_client.monitor_request(request["id"], { :max_time => 60 * 24})
end

