brpm_rest_client = BrpmRestClient.new
params = BrpmAuto.params
request_params = BrpmAuto.request_params

new_request_params = {}
new_request_params["calling_request"] = params["SS_request_number"]
new_request_params["application_version"] = request_params["application_version"]

BrpmAuto.log "Creating a new request from template 'Create image for BRPM' for BRPM v#{request_params["application_version"]} ..."
new_request = brpm_rest_client.create_request_for_plan_from_template(
    params["request_plan_id"].to_i,
    "Packaging",
    "Create image for BRPM",
    "Create image for BRPM v#{request_params["application_version"]}",
    "[default]",
    false, #execute_now
    new_request_params
)

BrpmAuto.log "Planning the request ... "
brpm_rest_client.plan_request(new_request["id"])

BrpmAuto.log "Starting the request ... "
brpm_rest_client.start_request(new_request["id"])

BrpmAuto.log "Waiting until the request has finished ..."
brpm_rest_client.monitor_request(new_request["id"], { :max_time => params["max_time"], :checking_interval => params["checking_interval"] })
