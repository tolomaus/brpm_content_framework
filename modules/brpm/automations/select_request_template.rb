def execute_script(params)
  BrpmAuto.log "Adding request template '#{params["request_template_id"]}' to the request_params..."
  RequestParams.add_request_param("request_template_id", params["request_template_id"])
end

