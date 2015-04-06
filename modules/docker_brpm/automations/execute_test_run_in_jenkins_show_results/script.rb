require "framework/lib/request_params"

def execute_script(params)
  request_params = get_request_params()

  pack_response "test_results_url", request_params["test_results_url"]
end


