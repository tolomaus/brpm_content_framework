require "framework/lib/request_params"

def execute_script(params)
  Logger.log "Storing the input parameters ..."
  request_params = {}
  request_params["application_version"] = params["application_version"]
  request_params["instance_name"] = params["instance_name"]
  request_params["port"] = params["port"]
  request_params["overwrite_existing_data"] = params["overwrite_existing_data"]

  set_request_params(request_params) unless request_params_exist?
end


