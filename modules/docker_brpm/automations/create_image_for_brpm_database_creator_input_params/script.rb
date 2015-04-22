require "framework/lib/request_params"

def execute_script(params)
  BrpmAuto.log "Storing the input parameters ..."
  request_params = {}
  request_params["application_version"] = params["application_version"]

  set_request_params(request_params) unless request_params_exist?
end


