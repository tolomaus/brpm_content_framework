require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"

def execute_script(params)
  request_params = get_request_params

  number_of_servers = params["Number of Servers"]

  new_requests = []
  (1..number_of_servers.to_i).each do |counter|
    new_request_params = {}
    new_request_params["input_name"] = "VMware #{params["application"]} #{params["component"]} #{counter}"
    new_request_params["input_virtual_guest_package"] = params["Virtual Guest Package"]
    new_request_params["input_processors"] = params["Processors"]
    new_request_params["input_memory"] = params["Memory"]
    new_request_params["input_network_storage"] = params["Network Storage"]
    new_request_params["input_am_application"] = params["application"]
    new_request_params["input_am_component"] = params["component"]
    new_request_params["input_am_environment"] = request_params["input_am_environment"]

    Logger.log "Creating a new request from template 'Provisioning - VMware' for provisioning server #{counter} for #{params["application"]} #{params["component"]} #{request_params["input_am_environment"]} ..."
    new_requests << create_request(
        "Provision server - VMware",
        "Provisioning - VMware #{params["application"]} #{params["component"]} #{request_params["input_am_environment"]}",
        "[default]",
        true, #execute_now
        new_request_params
    )
  end

  Logger.log "Waiting until the requests have finished ..."
  new_requests.each do |new_request|
    monitor_request(new_request["id"])
  end
end


