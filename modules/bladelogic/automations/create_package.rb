def execute_script(params)
  bl_build_component_name = first_defined(BrpmAuto.substitute_tokens(params["bl_build_component_name"]), "#{params["component"]} - build")
  depot_group_path = first_defined(BrpmAuto.substitute_tokens(params["depot_group_path"]), "/Applications/#{params["application"]}/#{params["component"]}")
  package_name = first_defined(BrpmAuto.substitute_tokens(params["bl_package_name"]), params["component_version"])

  BrpmAuto.log("Retrieving the key of the bl component of the build server #{bl_build_component_name}...")
  bl_build_component = Component.get_component_by_name(bl_build_component_name)

  BrpmAuto.log("Logging on to Bladelogic instance #{BsaSoap.get_url} with user #{BsaSoap.get_username} and role #{BsaSoap.get_role}...")
  session_id = BsaSoap.login

  BrpmAuto.log("Retrieving the id of the bl depot group of the package #{depot_group_path}...")
  depot_group_id = DepotGroup.group_name_to_id(session_id, {:group_name => depot_group_path})
  depot_group_id = depot_group_id.to_i #is this necessary?

  BrpmAuto.log("Creating blpackage #{depot_group_path}/#{package_name}...")
  BlPackage.create_package_from_component(session_id, {:package_name => package_name, :depot_group_id => depot_group_id, :component_key => bl_build_component["dbKey"]})

  BrpmAuto.log "Getting all environments of application #{params["application"]} ..."
  environments = BrpmRest.get_environments_of_application(params["application"])

  environments.each do |environment|
    BrpmAuto.log "Creating the version tag for version #{params["component_version"]} of application #{params["application"]} and component #{params["component"]} in environment #{environment["name"]} ..."
    environment = BrpmRest.create_version_tag(params["application"], params["component"], environment["name"], params["component_version"])
  end
end