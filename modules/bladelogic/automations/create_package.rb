params = BrpmAuto.params

bl_build_component_name = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["bl_build_component_name"]), "#{params["component"]} - build")
depot_group_path = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["depot_group_path"]), "/Applications/#{params["application"]}/#{params["component"]}")
package_name = BrpmAuto.first_defined(BrpmAuto.substitute_tokens(params["bl_package_name"]), params["component_version"])

BrpmAuto.log("Retrieving the key of the bl component of the build server #{bl_build_component_name}...")
bsa_rest_client = BsaRestClient.new
bl_build_component = bsa_rest_client.get_component_by_name(bl_build_component_name)

BrpmAuto.log("Logging on to Bladelogic...")
bsa_soap_client = BsaSoapClient.new

BrpmAuto.log("Retrieving the id of the bl depot group of the package #{depot_group_path}...")
depot_group_id = bsa_soap_client.depot_group.group_name_to_id({:group_name => depot_group_path})
depot_group_id = depot_group_id.to_i #is this necessary?

BrpmAuto.log("Creating blpackage #{depot_group_path}/#{package_name}...")
bsa_soap_client.blpackage.create_package_from_component({:package_name => package_name, :depot_group_id => depot_group_id, :component_key => bl_build_component["dbKey"]})

brpm_rest_client = BrpmRestClient.new

BrpmAuto.log "Getting all environments of application #{params["application"]} ..."
environments = brpm_rest_client.get_environments_of_application(params["application"])

environments.each do |environment|
  BrpmAuto.log "Creating the version tag for version #{params["component_version"]} of application #{params["application"]} and component #{params["component"]} in environment #{environment["name"]} ..."
  environment = brpm_rest_client.create_version_tag(params["application"], params["component"], environment["name"], params["component_version"])
end
