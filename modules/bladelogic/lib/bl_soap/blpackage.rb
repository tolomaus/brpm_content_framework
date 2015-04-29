class BlPackage < BsaSoapBase
  def create_package_from_component(options = {})
    validate_cli_options_hash([:package_name, :depot_group_id, :component_key], options)
    integer_result = execute_cli_with_param_list(self.class, "createPackageFromComponent",
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
    integer_value = get_cli_return_value(integer_result)
  rescue => exception
    raise "Exception executing #{self.class} function: #{exception.to_s}"
  end

  def delete_blpackage_by_group_and_name(options = {})
    validate_cli_options_hash([:parent_group, :package_name], options)
    integer_result = execute_cli_with_param_list(self.class, "deleteBlPackageByGroupAndName",
                                                              [
                                                                  options[:parent_group],
                                                                  options[:package_name],
                                                              ])
    integer_value = get_cli_return_value(integer_result)
  rescue => exception
    raise "Exception executing #{self.class} function: #{exception.to_s}"
  end

  def get_dbkey_by_group_and_name(options = {})
    validate_cli_options_hash([:parent_group, :depot_group_path], options)
    integer_result = execute_cli_with_param_list(self.class, "getDBKeyByGroupAndName",
                                                              [
                                                                  options[:parent_group],
                                                                  options[:depot_group_path],
                                                              ])
    integer_value = get_cli_return_value(integer_result)
  rescue => exception
    raise "Exception executing #{self.class} function: #{exception.to_s}"
  end
end