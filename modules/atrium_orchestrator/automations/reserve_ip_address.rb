params = BrpmAuto.params
request_params = BrpmAuto.request_params

host_name = request_params["input_name"]

BrpmAuto.log("Creating the AO client...")
ao_soap_client = AoSoapClient.new

BrpmAuto.log("Reserving an IP address in AO ...")
ip_address = ao_soap_client.reserve_ip_address(host_name)

BrpmAuto.log("Adding the IP address to the request-level parameters ...")
request_params["input_ip_address"] = ip_address
request_params["input_subnet_mask"] = "255.255.255.0"
request_params["input_gateway"] = "192.168.1.1"
request_params["input_dhcp"] = "No"
request_params["input_dns"] = ""
request_params["input_ip_resolution"] = "File"

BrpmAuto.log("Showing the IP address in the output field ...")
pack_response "IP address", ip_address

