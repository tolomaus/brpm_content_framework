require "brpm/lib/brpm_rest_api"
require "bladelogic/lib/bl_soap/component"
require "bladelogic/lib/bl_soap/depot"
require "bladelogic/lib/bl_soap/blpackage"
require "bladelogic/lib/bl_rest/component"

def execute_script(params)
  BsaSoap.disable_verbose_logging

  bsa_base_url = params["SS_integration_dns"]
  bsa_username = params["SS_integration_username"]
  bsa_password = params.has_key?("SS_integration_password") ? params["SS_integration_password"] : decrypt_string_with_prefix(params["SS_integration_password_enc"])

  bsa_role = params["SS_integration_details"]["role"]

  bl_build_component_name = first_defined(sub_tokens(params, params["bl_build_component_name"]), "#{params["component"]} - build")
  depot_group_path = first_defined(sub_tokens(params, params["depot_group_path"]), "/Applications/#{params["application"]}/#{params["component"]}")
  package_name = first_defined(sub_tokens(params, params["bl_package_name"]), params["component_version"])

  Logger.log("Retrieving the key of the bl component of the build server #{bl_build_component_name}...")
  BsaRest::Component.initialize(bsa_base_url, bsa_username, bsa_password, bsa_role)
  bl_build_component = BsaRest::Component.get_component_by_name(bl_build_component_name)

  Logger.log("Logging on to Bladelogic instance #{bsa_base_url} with user #{bsa_username} and role #{bsa_role}...")
  session_id = BsaSoap.login_with_role(bsa_base_url, bsa_username, bsa_password, bsa_role)

  Logger.log("Retrieving the id of the bl depot group of the package #{depot_group_path}...")
  depot_group_id = DepotGroup.group_name_to_id(bsa_base_url, session_id, {:group_name => depot_group_path})
  depot_group_id = depot_group_id.to_i #is this necessary?

  Logger.log("Creating blpackage #{depot_group_path}/#{package_name}...")
  BlPackage.create_package_from_component(bsa_base_url, session_id, {:package_name => package_name, :depot_group_id => depot_group_id, :component_key => bl_build_component["dbKey"]})

  Logger.log "Getting all environments of application #{params["application"]} ..."
  environments = get_environments_of_application(params["application"])

  environments.each do |environment|
    Logger.log "Creating the version tag for version #{params["component_version"]} of application #{params["application"]} and component #{params["component"]} in environment #{environment["name"]} ..."
    environment = create_version_tag(params["application"], params["component"], environment["name"], params["component_version"])
  end
end