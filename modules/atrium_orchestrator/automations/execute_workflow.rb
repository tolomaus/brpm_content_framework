params = BrpmAuto.params

workflow = params["workflow_list"].index(params["workflow"].strip)

server_group = "/#{BrpmRestClient.new.get_server_group_from_step_id(params["step_id"])}"

BrpmAuto.log("Creating the AO client...")
ao_soap_client = AoSoapClient.new

BrpmAuto.log("Executing workflow #{workflow} in AO ...")
ao_soap_client.execute_workflow("#{params["application"].downcase}-#{workflow}", { "server_group" => server_group })
BrpmAuto.log("Done.")
