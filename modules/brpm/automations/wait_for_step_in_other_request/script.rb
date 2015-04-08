require "brpm/lib/brpm_rest_api"

def execute_script(params)
  req_step = params["other_request_step"].split("|")
  request_id = req_step[0].to_i
  step_id = req_step[1].to_i

  brpm_client = Brpm::Client.new(params["SS_base_url"], params["SS_api_token"])

  Logger.log "Monitoring step #{step_id} of request #{request_id} ..."
  brpm_client.monitor_request(request_id, { :monitor_step_id => step_id })
end


