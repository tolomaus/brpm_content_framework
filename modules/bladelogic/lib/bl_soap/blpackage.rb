require "bladelogic/lib/bl_soap/soap"

class BlPackage
  class << self
    def create_package_from_component(session_id, options = {})
      BsaSoap.validate_cli_options_hash([:package_name, :depot_group_id, :component_key], options)
      integer_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "createPackageFromComponent",
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
      integer_value = BsaSoap.get_cli_return_value(integer_result)
    rescue => exception
      raise "Exception executing #{self.name} function: #{exception.to_s}"
    end

    def delete_blpackage_by_group_and_name(session_id, options = {})
      BsaSoap.validate_cli_options_hash([:parent_group, :package_name], options)
      integer_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "deleteBlPackageByGroupAndName",
                                                                [
                                                                    options[:parent_group],
                                                                    options[:package_name],
                                                                ])
      integer_value = BsaSoap.get_cli_return_value(integer_result)
    rescue => exception
      raise "Exception executing #{self.name} function: #{exception.to_s}"
    end

    def get_dbkey_by_group_and_name(session_id, options = {})
      BsaSoap.validate_cli_options_hash([:parent_group, :depot_group_path], options)
      integer_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "getDBKeyByGroupAndName",
                                                                [
                                                                    options[:parent_group],
                                                                    options[:depot_group_path],
                                                                ])
      integer_value = BsaSoap.get_cli_return_value(integer_result)
    rescue => exception
      raise "Exception executing #{self.name} function: #{exception.to_s}"
    end
  end
end