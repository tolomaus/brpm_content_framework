require "framework/lib/request_params"

def execute_script(params)
  Logger.log "Adding request template '#{params["request_template_id"]}' to the request_params..."
  add_request_param("request_template_id", params["request_template_id"])
end

