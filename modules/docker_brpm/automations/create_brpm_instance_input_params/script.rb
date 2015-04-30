params = BrpmAuto.params
request_params = BrpmAuto.request_params

BrpmAuto.log "Storing the input parameters ..."
request_params["application_version"] = params["application_version"]
request_params["instance_name"] = params["instance_name"]
request_params["port"] = params["port"]
request_params["overwrite_existing_data"] = params["overwrite_existing_data"]


