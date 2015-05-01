params = BrpmAuto.params
request_params = BrpmAuto.request_params

BrpmAuto.log "Storing the input parameters ..."
request_params["application_version"] = params["application_version"] unless request_params["application_version"]


