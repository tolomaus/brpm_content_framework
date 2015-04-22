def execute_script(params)
  request_params = RequestParams.get_request_params()

  BrpmAuto.log "Getting the request ..."
  request = BrpmRest.get_request_by_id(request_params["promoted_request_id"])

  BrpmAuto.log "Waiting until the request has finished ..."
  BrpmRest.monitor_request(request["id"], { :max_time => 60 * 24})
end

