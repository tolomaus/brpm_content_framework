def execute_script(params)
  req_step = params["other_request_step"].split("|")
  request_id = req_step[0].to_i
  step_id = req_step[1].to_i

  Logger.log "Monitoring step #{step_id} of request #{request_id} ..."
  BrpmRest.monitor_request(request_id, { :monitor_step_id => step_id })
end


