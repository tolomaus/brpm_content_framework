require "framework/lib/request_params"
require "brpm/lib/brpm_rest_api"
require "rapid_provisioning/lib/baa_provision_vm"

def execute_script(params)
  request_params = get_request_params()

  request_params.each do |key, value|
    Logger.log("#{key} = #{value}")
  end

  environment = nil
  if request_params.include?("input_am_environment")
    Logger.log "Getting the environment ..."
    environment = get_environment_by_name(request_params["input_am_environment"])
    if environment.nil?
      environment = create_environment(request_params["input_am_environment"])
      link_environment_to_app(environment["id"], request_params["input_am_application"]) if request_params.include?("input_am_application")
    end
  end

  Logger.log "Getting the property id's ..."
  properties_by_id = {}
  request_params.each do |key, value|
    if key.start_with?("input_") and !key.start_with?("input_am_")
      property_name = key.dup
      property_name.slice!("input_")
      property_name = "provisioning_vmware_#{property_name}"

      property = get_property_by_name(property_name)
      properties_by_id[property["id"]] = value
    end
  end

  Logger.log "Provisioning the server in BladeLogic ..."
  vm_params = {}
  vm_params["baa_username"] = params["SS_integration_username"]
  vm_params["baa_password_enc"] = params["SS_integration_password_enc"]
  vm_params["baa_role"] = params["SS_integration_role"]
  vm_params["baa_authentication_mode"] = params["SS_integration_authentication_mode"]
  vm_params["baa_base_url"] = params["SS_integration_dns"]
  vm_params["brpm_base_url"] = params["SS_base_url"]

  vm_params["HostName"] = request_params["input_name"]
  vm_params["Hypervisor"] = request_params["input_hypervisor"]
  vm_params["Location"] = request_params["input_target_for_virtual_guest"]
  vm_params["VMTemplate"] = request_params["input_virtual_guest_package"]
  vm_params["Domain"] = ""

  vm_params["IPaddress"] = request_params["input_ip_address"]
  vm_params["SubnetMask"] = request_params["input_subnet_mask"]
  vm_params["Gateway"] = request_params["input_gateway"]
  vm_params["DHCP"] = request_params["input_dhcp"]
  vm_params["DNS"] = request_params["input_dns"]
  vm_params["IPResolution"] = request_params["input_ip_resolution"]

  provision_vm(vm_params)

  Logger.log "Creating the server in the BRPM cmdb ..."
  server = create_server(request_params["input_name"], nil, [ environment["id"] ], nil, request_params["input_virtual_guest_package"], properties_by_id.keys)

  Logger.log "Setting the server properties ..."
  properties_by_id.each do |property_id, property_value|
    set_property_of_server(server["id"], property_id, property_value)
  end

  if request_params.include?("input_am_environment") and request_params.include?("input_am_application") and request_params.include?("input_am_component")
    Logger.log "Linking the app/comp/env to the server ..."
    create_installed_component(request_params["input_am_component"], nil, request_params["input_am_environment"], request_params["input_am_application"], request_params["input_name"])
  end
end


