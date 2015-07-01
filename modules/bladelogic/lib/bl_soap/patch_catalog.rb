class PatchCatalog < BsaSoapBase
  # internal function
  def internal_delete_obsolete_patches(cmd, options = {})
    validate_cli_options_hash([:catalog_name], options)
    deleted_count_result = execute_cli_with_param_list(self.class, cmd,
      [
        options[:catalog_name]	# Fully qualified catalog name
      ])
    deleted_count = get_cli_return_value(deleted_count_result)
  rescue => exception
    raise "Problem executing #{self.class} command(#{cmd}): #{exception.to_s}"
  end
  
  def internal_execute_update_and_wait(cmd, options = {})
    validate_cli_options_hash([:group_name], options)
    job_run_key_result = execute_cli_with_param_list(self.class, cmd,
      [
        options[:group_name]	# Fully qualified catalog name
      ])
    job_run_key = get_cli_return_value(job_run_key_result)
  rescue => exception
    raise "Problem executing #{self.class} command(#{cmd}): #{exception.to_s}"
  end
  
  def delete_obsolete_patches_from_aix_catalog( options = {})
    deleted_count = self.internal_delete_obsolete_patches("deleteObsoletePatchesFromAixCatalog", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def delete_obsolete_patches_from_other_linux_catalog(options = {})
    deleted_count = self.internal_delete_obsolete_patches("deleteObsoletePatchesFromOtherLinuxCatalog", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def delete_obsolete_patches_from_redhat_linux_catalog(options = {})
    deleted_count = self.internal_delete_obsolete_patches("deleteObsoletePatchesFromRedhatLinuxCatalog", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def delete_obsolete_patches_from_solaris_catalog(options = {})
    deleted_count = self.internal_delete_obsolete_patches("deleteObsoletePatchesFromSolarisCatalog", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def delete_obsolete_patches_from_windows_catalog(options = {})
    deleted_count = self.internal_delete_obsolete_patches("deleteObsoletePatchesFromWindowsCatalog", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def execute_aix_catalog_update_and_wait(options = {})
    job_run_key = self.internal_delete_obsolete_patches("executeAixCatalogUpdateAndWait", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def execute_other_linux_catalog_update_and_wait(options = {})
    job_run_key = self.internal_delete_obsolete_patches("executeOtherLinuxCatalogUpdateAndWait", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def execute_redhat_catalog_update_and_wait(options = {})
    job_run_key = self.internal_delete_obsolete_patches("executeRedhatCatalogUpdateAndWait", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def execute_solaris_catalog_update_and_wait(options = {})
    job_run_key = self.internal_delete_obsolete_patches("executeSolarisCatalogUpdateAndWait", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def execute_windows_catalog_update_and_wait(options = {})
    job_run_key = self.internal_delete_obsolete_patches("executeWindowsCatalogUpdateAndWait", options)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def get_cuj_dbkey_by_fully_qualified_catalog_name(options = {})
    validate_cli_options_hash([:type, :group_name], options)
    validate_cli_option_hash_string_values(["WINDOWS", "REDHAT", "SOLARIS", "AIX", "OTHERLINUX"],options[:type])
    db_key_result = execute_cli_with_param_list(self.class, "getCUJDBKeyByFullyQualifiedCatalogName",
      [
        options[:type],		# Type of catalog: WINDOWS, REDHAT, SOLARIS, AIX, OTHERLINUX
        option[:group_name]	# Fully qualified name of patch catalog
      ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def get_dbkey_by_type_and_name_from_catalog(options = {})
    validate_cli_options_hash([:depot_group_type, :depot_object_type, :group_name, :depot_object_name], options)
    validate_cli_options_hash_string_values(
      [
        "RED_HAT_CATALOG_GROUP",	# RedHat Catalog
        "SOLARIS_CATALOG_GROUP",	# Solaris Catalog
        "WINDOWS_CATALOG_GROUP",	# Windows Catalog
        "OTHER_LINUX_CATALOG_GROUP"	# Other Linux Catalog
      ], options[:depot_group_type])
    validate_cli_options_hash_string_values(
      [
        "AIX_FILESET_INSTALLABLE",				# AIX Fileset
        "AIX_CONTAINER_INSTALLABLE",			# AIX Patch Container
        "RPM_INSTALLABLE",						# Linux RPM
        "ERRATA_INSTALLABLE",					# Linux Errata
        "SOLARIS_PATCH_INSTALLABLE",			# Solaris Path
        "SOLARIS_PATCH_TCLUSTER_INSTALLABLE",	# Solaris Cluster
        "HOTFIX_WINDOWS_INSTALLABLE", 			# Windows HotFix
        "WINDOWS_BULLETIN_INSTALLABLE"			# Windows Bulletin
      ], options[:dept_object_type])
    db_key = execute_cli_with_param_list(self.class, "getDBKeyByTypeAndNameFromCatalog",
      [
        options[:depot_group_type],		# String representation of catalog type
        options[:depot_object_type],	# String representation of depot object type
        options[:group_name],			# Fully qualified path to parent depot group
        options[:depot_object_name]		# Name of depot object
      ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def list_all_by_catalog_name_and_type(options = {})
    validate_cli_options_hash([:qualified_group_name, :catalog_type_string], options)
    validate_cli_options_hash_string_values(
      [
        "WINDOWS_CATALOG_GROUP",		# Windows Catalog
        "SOLARIS_CATALOG_GROUP",		# Solaris Catalog
        "RED_HAT_CATALOG_GROUP",		# Redhat Catalog
        "OTHER_LINUX_CATALOG_GROUP",	# Other Linux Catalog
        "AIX_CATALOG_GROUP"				# AIX Catalog
      ], options[:catalog_type_string])
    string_result = execute_cli_with_param_list(self.class, "listAllByCatalogNameAndType",
      [
        options[:qualified_group_name],	# Name of depot group whose objects you want to list
        options[:catalog_type_string]	# String representation of depot object type
      ])
    str_value = get_cli_return_value(dstring_result)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
  
  def recursively_set_property_for_catalog(options ={})
    validate_cli_options_hash([:group_path, :property_name, :value, :catalog_type_string], options)
    validate_cli_options_hash_string_values(
      [
        "RPM_INSTALLABLE",						# Linux RPM
        "SOLARIS_PATCH_INSTALLABLE",			# Solaris Patch
        "HOTFIX_WINDOWS_INSTALLABLE",			# Windows HotFix
        "WINDOWS_BULLETIN_INSTALLABLE",			# Windows Bulletin
        "ERRATA_INSTALLABLE",					# Redhat Errata
        "SOLARIS_PATCH_TCLUSTER_INSTALLABLE",	# Solaris Patch Cluster
        "AIX_FILESET_INSTALLABLE",				# AIX Fileset
        "AIX_CONTAINER_INSTALLABLE"				# AIX Container
      ], options[:catalog_type_string])
    void_result = execute_cli_with_param_list(self.class, "recursivelySetPropertyForCatalog",
      [
        options[:group_path],			# The path to the folder
        options[:property_name],		# The name of the property to set
        options[:value],				# The value to set
        options[:catalog_type_string]	# String representation of depot object type
      ])
    void_value = get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.class} Execution Exception: #{exception.to_s}"
  end
end




