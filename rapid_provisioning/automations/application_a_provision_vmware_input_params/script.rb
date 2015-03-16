require "framework/lib/request_params"

def execute_script(params)
  add_request_param("input_am_environment", params["Environment"])
end


