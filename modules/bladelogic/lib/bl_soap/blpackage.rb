require "bladelogic/lib/bl_soap/soap"

module BsaBlPackage
	extend BsaSoap
end

class BlPackage
  def self.create_package_from_component(url, session_id, options = {})
    BsaBlPackage.validate_cli_options_hash([:package_name, :depot_group_id, :component_key], options)
    integer_result = BsaBlPackage.execute_cli_with_param_list(url, session_id, self.name, "createPackageFromComponent",
      [
          options[:package_name],
          options[:depot_group_id],
          false, #bSoftLinked
          false, #bCollectFileAcl
          false, #bCollectFileAttributes
          true, #bCopyFileContents
          false, #bCollectRegistryAcl
          options[:component_key]
      ])
    integer_value = BsaBlPackage.get_cli_return_value(integer_result)
  rescue => exception
    raise "Exception executing #{self.name} function: #{exception.to_s}"
  end

  def self.get_dbkey_by_group_and_name(url, session_id, options = {})
    BsaBlPackage.validate_cli_options_hash([:parent_group, :depot_group_path], options)
    integer_result = BsaBlPackage.execute_cli_with_param_list(url, session_id, self.name, "getDBKeyByGroupAndName",
                                                              [
                                                                  options[:parent_group],
                                                                  options[:depot_group_path],
                                                              ])
    integer_value = BsaBlPackage.get_cli_return_value(integer_result)
  rescue => exception
    raise "Exception executing #{self.name} function: #{exception.to_s}"
  end
end