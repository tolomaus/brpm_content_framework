require "framework/lib/request_params"
require "atrium_orchestrator/lib/ao_soap_api"

def execute_script(params)
  host_name = get_request_params()["input_name"]

  BrpmAuto.log("Setting up the AO connection parameters ...")
  set_ao_soap_api_url(params["SS_integration_dns"])
  set_ao_soap_api_username(params["SS_integration_username"])
  set_ao_soap_api_password(decrypt_string_with_prefix(params["SS_integration_password_enc"]))
  set_ao_soap_api_grid_name(params["grid_name"])
  set_ao_soap_api_module_name(params["module_name"])

  BrpmAuto.log("Reserving an IP address in AO ...")
  ip_address = ao_reserve_ip_address(host_name)

  BrpmAuto.log("Adding the IP address to the request-level parameters ...")
  add_request_param("input_ip_address", ip_address)
  add_request_param("input_subnet_mask", "255.255.255.0")
  add_request_param("input_gateway", "192.168.1.1")
  add_request_param("input_dhcp", "No")
  add_request_param("input_dns", "")
  add_request_param("input_ip_resolution", "File")

  BrpmAuto.log("Showing the IP address in the output field ...")
  pack_response "IP address", ip_address
end

