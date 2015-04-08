require "framework/lib/request_params"

def execute_script(params)
  request_params_manager = Framework::RequestParamsManager.new(params["SS_output_dir"])

  Logger.log "Adding request template '#{params["request_template_id"]}' to the request_params..."
  request_params_manager.add_request_param("request_template_id", params["request_template_id"])
end

