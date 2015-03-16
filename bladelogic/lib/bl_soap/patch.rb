require "bladelogic/lib/bl_soap/soap"

#
# BsaPatch Module
#
module BsaPatch
	extend BsaSoap
end

#module PatchClass
	class PatchCatalog
		# internal function
		def self.internal_delete_obsolete_patches(url, session_id, cmd, options = {})
			BsaPatch.validate_cli_options_hash([:catalog_name], options)
			deleted_count_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, cmd,
				[
					options[:catalog_name]	# Fully qualified catalog name
				])
			deleted_count = BsaPatch.get_cli_return_value(deleted_count_result)
		rescue => exception
			raise "Problem executing #{self.name} command(#{cmd}): #{exception.to_s}"
		end
		
		def self.internal_execute_update_and_wait(url, session_id, cmd, options = {})
			BsaPatch.validate_cli_options_hash([:group_name], options)
			job_run_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, cmd,
				[
					options[:group_name]	# Fully qualified catalog name
				])
			job_run_key = BsaPatch.get_cli_return_value(job_run_key_result)
		rescue => exception
			raise "Problem executing #{self.name} command(#{cmd}): #{exception.to_s}"
		end
		
		def self.delete_obsolete_patches_from_aix_catalog(url, session_id,  options = {})
			deleted_count = self.internal_delete_obsolete_patches(url, session_id, "deleteObsoletePatchesFromAixCatalog", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.delete_obsolete_patches_from_other_linux_catalog(url, session_id, options = {})
			deleted_count = self.internal_delete_obsolete_patches(url, session_id, "deleteObsoletePatchesFromOtherLinuxCatalog", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.delete_obsolete_patches_from_redhat_linux_catalog(url, session_id, options = {})
			deleted_count = self.internal_delete_obsolete_patches(url, session_id, "deleteObsoletePatchesFromRedhatLinuxCatalog", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.delete_obsolete_patches_from_solaris_catalog(url, session_id, options = {})
			deleted_count = self.internal_delete_obsolete_patches(url, session_id, "deleteObsoletePatchesFromSolarisCatalog", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.delete_obsolete_patches_from_windows_catalog(url, session_id, options = {})
			deleted_count = self.internal_delete_obsolete_patches(url, session_id, "deleteObsoletePatchesFromWindowsCatalog", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.execute_aix_catalog_update_and_wait(url, session_id, options = {})
			job_run_key = self.internal_delete_obsolete_patches(url, session_id, "executeAixCatalogUpdateAndWait", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.execute_other_linux_catalog_update_and_wait(url, session_id, options = {})
			job_run_key = self.internal_delete_obsolete_patches(url, session_id, "executeOtherLinuxCatalogUpdateAndWait", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.execute_redhat_catalog_update_and_wait(url, session_id, options = {})
			job_run_key = self.internal_delete_obsolete_patches(url, session_id, "executeRedhatCatalogUpdateAndWait", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.execute_solaris_catalog_update_and_wait(url, session_id, options = {})
			job_run_key = self.internal_delete_obsolete_patches(url, session_id, "executeSolarisCatalogUpdateAndWait", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.execute_windows_catalog_update_and_wait(url, session_id, options = {})
			job_run_key = self.internal_delete_obsolete_patches(url, session_id, "executeWindowsCatalogUpdateAndWait", options)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.get_cuj_dbkey_by_fully_qualified_catalog_name(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:type, :group_name], options)
			BsaPatch.validate_cli_option_hash_string_values(["WINDOWS", "REDHAT", "SOLARIS", "AIX", "OTHERLINUX"],options[:type])
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "getCUJDBKeyByFullyQualifiedCatalogName",
				[
					options[:type],		# Type of catalog: WINDOWS, REDHAT, SOLARIS, AIX, OTHERLINUX
					option[:group_name]	# Fully qualified name of patch catalog
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.get_dbkey_by_type_and_name_from_catalog(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:depot_group_type, :depot_object_type, :group_name, :depot_object_name], options)
			BsaPatch.validate_cli_options_hash_string_values(
				[
					"RED_HAT_CATALOG_GROUP",	# RedHat Catalog
					"SOLARIS_CATALOG_GROUP",	# Solaris Catalog
					"WINDOWS_CATALOG_GROUP",	# Windows Catalog
					"OTHER_LINUX_CATALOG_GROUP"	# Other Linux Catalog
				], options[:depot_group_type])
			BsaPatch.validate_cli_options_hash_string_values(
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
			db_key = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "getDBKeyByTypeAndNameFromCatalog", 
				[
					options[:depot_group_type],		# String representation of catalog type
					options[:depot_object_type],	# String representation of depot object type
					options[:group_name],			# Fully qualified path to parent depot group
					options[:depot_object_name]		# Name of depot object
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.list_all_by_catalog_name_and_type(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:qualified_group_name, :catalog_type_string], options)
			BsaPatch.validate_cli_options_hash_string_values(
				[
					"WINDOWS_CATALOG_GROUP",		# Windows Catalog
					"SOLARIS_CATALOG_GROUP",		# Solaris Catalog
					"RED_HAT_CATALOG_GROUP",		# Redhat Catalog
					"OTHER_LINUX_CATALOG_GROUP",	# Other Linux Catalog
					"AIX_CATALOG_GROUP"				# AIX Catalog
				], options[:catalog_type_string])
			string_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "listAllByCatalogNameAndType",
				[
					options[:qualified_group_name],	# Name of depot group whose objects you want to list
					options[:catalog_type_string]	# String representation of depot object type
				])
			str_value = BsaPatch.get_cli_return_value(dstring_result)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
		
		def self.recursively_set_property_for_catalog(url, session_id, options ={})
			BsaPatch.validate_cli_options_hash([:group_path, :property_name, :value, :catalog_type_string], options)
			BsaPatch.validate_cli_options_hash_string_values(
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
			void_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "recursivelySetPropertyForCatalog",
				[
					options[:group_path],			# The path to the folder
					options[:property_name],		# The name of the property to set
					options[:value],				# The value to set
					options[:catalog_type_string]	# String representation of depot object type
				])
			void_value = BsaPatch.get_cli_return_value(void_result)
		rescue => exception
			raise "#{self.name} Execution Exception: #{exception.to_s}"
		end
	end
	
	class PatchRemediationJob
		def self.create_remediation_job(url, session_id, options)
			BsaPatch.validate_cli_options_hash(
				[:remediation_name, :job_group_name, :pa_job_run_key, :pck_prefix, :depot_group_name, :dep_job_group_name],
				options)
				
				puts "Content from bsa_patch_utils "
				options.each_pair {|key,value| puts  "#{key} = #{value}" }
			
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "createRemediationJob",
				[
					options[:remediation_name],		# Name of the job
					options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
					options[:pa_job_run_key],		# Handle to the job run whose result you want to use for remediation
					options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
					options[:depot_group_name],		# Name of a group that should contain the new Package(s)
					options[:dep_job_group_name]	# Name of a group that should contain the generated Deploy Job(s)
				])
				
			db_key = BsaPatch.get_cli_return_value(db_key_result)
				
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_remediation_job_for_a_target(url, session_id, options)
			BsaPatch.validate_cli_options_hash(
				[:remediation_name, :job_group_name, :pa_job_run_key, :server_name, :pck_prefix, :depot_group_name, :dep_job_group_name],
				options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "createRemediationJobForATarget",
				[
					options[:remediation_name],		# Name of the job
					options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
					options[:pa_job_run_key],		# Handle to the job run whose result you want to use for remedation
					options[:server_name],			# Server where you want to run this job, should be one of the server where analysis was run
					options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
					options[:depot_group_name],		# Name of a group that should contain the new Package(s)
					options[:dep_job_group_name]	# Name of a group that should contain the generated Deploy Job(s)
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_remediation_job_with_deploy_opts(url, session_id, options)
			BsaPatch.validate_cli_options_hash(
				[:remediation_name, :job_group_name, :pa_job_run_key, :pck_prefix, :depot_group_name, :dep_job_group_name, :deploy_job_key],
				options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "createRemediationJobWithDeployOpts",
				[
					options[:remediation_name],		# Name of the job
					options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
					options[:pa_job_run_key],		# Hand to the patching job run whose results you want to use for remediation
					options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
					options[:depot_group_name],		# Name of a group that should contain the new Package(s)
					options[:dep_job_group_name],	# Name of a group that should contain the new generated Deploy Job(s)
					options[:deploy_job_key]		# Handle to the Deploy Job run whose options you want to use generated Deploy Job(s)
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_remediation_job_with_deploy_opts_for_a_target(url, session_id, options)
			BsaPatch.validate_cli_options_hash(
				[:remediation_name, :job_group_name, :pa_job_run_key, :server_name, :pck_prefix, :depot_group_name, :dep_job_group_name, :deploy_job_key],
				options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "createRemediationJobWithDeployOpts",
				[
					options[:remediation_name],		# Name of the job
					options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
					options[:pa_job_run_key],		# Hand to the patching job run whose results you want to use for remediation
					options[:server_name],			# Server where you want to run this job.  Server should  be a server which had an anaylsis run
					options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
					options[:depot_group_name],		# Name of a group that should contain the new Package(s)
					options[:dep_job_group_name],	# Name of a group that should contain the new generated Deploy Job(s)
					options[:deploy_job_key]		# Handle to the Deploy Job run whose options you want to use generated Deploy Job(s)
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end

		def self.modify_job_set_(url, session_id, options)
			BsaPatch.validate_cli_options_hash(
				[:remediation_name, :job_group_name, :pa_job_run_key, :server_name, :pck_prefix, :depot_group_name, :dep_job_group_name, :deploy_job_key],
				options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "createRemediationJobWithDeployOpts",
				[
					options[:remediation_name],		# Name of the job
					options[:job_group_name],		# Name of the group that should contain the new remediation job(s)
					options[:pa_job_run_key],		# Hand to the patching job run whose results you want to use for remediation
					options[:server_name],			# Server where you want to run this job.  Server should  be a server which had an anaylsis run
					options[:pck_prefix],			# Prefix for naming the new Batch Job/Deploy Job/Package(s)
					options[:depot_group_name],		# Name of a group that should contain the new Package(s)
					options[:dep_job_group_name],	# Name of a group that should contain the new generated Deploy Job(s)
					options[:deploy_job_key]		# Handle to the Deploy Job run whose options you want to use generated Deploy Job(s)
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end

		def self.execute_job_and_wait(url, session_id, options)
			BsaPatch.validate_cli_options_hash([:job_key], options)
			job_run_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "executeJobAndWait",
				[
					options[:job_key]	# Handle to the remediation job to be executed
				])
			job_run_key = BsaPatch.get_cli_return_value(job_run_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.execute_job_get_job_result_key(url, session_id, options)
			BsaPatch.validate_cli_options_hash([:job_key], options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "executeJobGetJobResultKey",
				[
					options[:job_key]	# Handle to the remediation job to be executed
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.get_dbkey_by_group_and_name(url, session_id, options)
			BsaPatch.validate_cli_options_hash([:group_name, :job_name], options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "getDBKeyByGroupAndName",
				[
					options[:group_name],	# Fully qualified path to the job group containing the job
					options[:job_name]		# Name of the job
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
	end
	
	class PatchingJob
		def self.internal_aix_execute(url, session_id, cmd, options = {})
			BsaPatch.validate_cli_options_hash([:job_name, :group_name, :target, :catalog_name, :include_file, :exclude_file],options)
			b_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, cmd,
				[
					options[:job_name],				# Name of job
					options[:group_name],			# Parent group of the job
					options[:target],				# Name of target (server, group, or smart group)
					options[:catalog_name],			# Catalog name
					options[:include_file],			# Include file path
					options[:exclude_file],			# Exclude file path
					options[:analysis_option] || 1,	# Analysis options:
													#   1 - Use global settings (DEFAULT)
													#   2 - Stop analysis if any applied fileset found
													#   3 - Continue analysis even if applied fileset found
					options[:analysis_mode] || 2	# Analysis mode:
													#   1 - Report on all missing filesets, the ones that are
													#       not install on the target
													#   2 - report only updates for the installed fileset on
													#       the target
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} #{cmd} Exception: #{exception.to_s}"
		end
		
		def self.internal_linux_execute(url, session_id, cmd, options = {})
			BsaPatch.validate_cli_options_hash([:job_name, :group_name, :target, :catalog_name, :include_file, :exclude_file],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, cmd,
				[
					options[:job_name],					# Name of job
					options[:group_name],				# Parent group of the job
					options[:target],					# Name of target (server, group, or smart group)
					options[:catalog_name],				# Catalog name
					options[:include_file],				# Include file path
					options[:exclude_file],				# Exclude file path
					options[:set_install_mode] || true,	# Install mode: true to set install mode, false otherwise
					options[:set_exact_arch] || false	# Architecture: true to use exact architecture match, false otherwise
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} #{cmd} Exception: #{exception.to_s}"
		end
		
		def self.internal_redhat_execute(url, session_id, cmd, options = {})
			BsaPatch.validate_cli_options_hash([:job_name, :group_name, :target],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, cmd,
				[
					options[:job_name],					# Name of job
					options[:group_name],				# Parent group of the job
					options[:target],					# Name of target (server, group, or smart group)
					options[:catalog_name] || "",		# Catalog name
					options[:include_file] || "",		# Include file path
					options[:exclude_file] || "",		# Exclude file path
					options[:set_install_mode] || true	# Install mode: true to set install mode, false otherwise
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} #{cmd} Exception: #{exception.to_s}"
		end
		
		def self.internal_solaris_execute(url, session_id, cmd, options = {})
			BsaPatch.validate_cli_options_hash([:job_name, :group_name, :target, :catalog_name, :include_file, :exclude_file],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, cmd,
				[
					options[:job_name],						# Name of job
					options[:group_name],					# Parent group of the job
					options[:target],						# Name of target (server, group, or smart group)
					options[:catalog_name],					# Catalog name
					options[:include_file],					# Include file path
					options[:exclude_file],					# Exclude file path
					options[:recommended_only] || true,		# Analyze recommended patches only, false otherwise
					options[:security_only] || false,		# Analyze security patches only, false otherwise
					options[:without_dependencies] || false	# Analyze without dependencies, false otherwise
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} #{cmd} Exception: #{exception.to_s}"
		end
		
		def self.internal_windows_execute(url, session_id, cmd, options = {})
			BsaPatch.validate_cli_options_hash([:job_name, :group_name, :target, :catalog_name, :include_file, :exclude_file],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, cmd,
				[
					options[:job_name],									# Name of job
					options[:group_name],								# Parent group of the job
					options[:target],									# Name of target (server, group, or smart group)
					options[:catalog_name],								# Catalog name
					options[:include_file],								# Include file path
					options[:exclude_file],								# Exclude file path
					options[:analyze_security_tools] || true,			# Analyze security tools, false otherwise
					options[:analyze_security_patches] || false,		# Analyze security patches, false otherwise
					options[:analyze_non_security_patches] || false,	# Analyze non-security patches, false otherwise
					options[:filter_service_packs] || false				# Filter services packs, false otherwise
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} #{cmd} Exception: #{exception.to_s}"
		end
		
		def self.create_aix_patching_job_with_target_group(url, session_id, options = {})
			db_key = self.internal_aix_execute(url, session_id, "createAixPatchingJobWithTargetGroup", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_aix_patching_job_with_target_server(url, session_id, options = {})
			db_key = self.internal_aix_execute(url, session_id, "createAixPatchingJobWithTargetServer", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_download_job_for_missing_patches(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:pa_job_run_key, :job_name, :dep_job_group_name],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "createDownloadJobForMissingPatches", 
				[
					options[:pa_job_run_key],		# Handle to the patching job run
					options[:job_name],				# Name of the download job
					options[:dep_job_group_name]	# Name of a group that should contain the download job
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_other_linux_patching_job_with_target_group(url, session_id, options = {})
			db_key = self.internal_linux_execute(url, session_id, "createOtherLinuxPatchingJobWithTargetGroup", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_other_linux_patching_job_with_target_server(url, session_id, options = {})
			db_key = self.internal_linux_execute(url, session_id, "createOtherLinuxPatchingJobWithTargetServer", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_redhat_patching_job_with_target_group(url, session_id, options = {})
			db_key = self.internal_redhat_execute(url, session_id, "createRedhatPatchingJobWithTargetGroup", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_redhat_patching_job_with_target_server(url, session_id, options = {})
			db_key = self.internal_redhat_execute(url, session_id, "createRedhatPatchingJobWithTargetServer", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_solaris_patching_job_with_target_group(url, session_id, options = {})
			db_key = self.internal_solaris_execute(url, session_id, "createSolarisPatchingJobWithTargetGroup", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_solaris_patching_job_with_target_server(url, session_id, options = {})
			db_key = self.internal_solaris_execute(url, session_id, "createSolarisPatchingJobWithTargetServer", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_windows_patching_job_with_target_group(url, session_id, options = {})
			db_key = self.internal_windows_execute(url, session_id, "createWindowsPatchingJobWithTargetGroup", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.create_windows_patching_job_with_target_server(url, session_id, options = {})
			db_key = self.internal_windows_execute(url, session_id, "createWindowsPatchingJobWithTargetServer", options)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.delete_job_by_group_and_name(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:parent_group, :job_name],options)
			void_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "deleteJobByGroupAndName",
				[
					options[:parent_group],	# Fully qualifed path to the job group containing the patching job
					options[:job_name]		# Name of the patching job
				])
			void_value = BsaPatch.get_cli_return_value(void_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.execute_job_and_wait(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:job_key],options)
			job_run_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "executeJobAndWait",
				[
					options[:job_key]	# Handle to the patching job to execute
				])
			job_run_key = BsaPatch.get_cli_return_value(job_run_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.get_dbkey_by_group_and_name(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:group_name, :job_name],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "getDBKeyByGroupAndName",
				[
					options[:group_name],	# Fully qualified path the the job group containing the job
					options[:job_name]		# Name of the job
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.set_description(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:job_key, :desc],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "setDescription",
				[
					options[:job_key],	# the handle to the patching job
					options[:job_name]	# the description for the job
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.set_remediation_options(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:patching_job_key, :pck_prefix, :depot_group_name, :depot_job_group_name],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "setRemediationOptions",
				[
					options[:patching_job_key],		# handle to the patching job
					options[:pck_prefix],			# prefix for naming the new batch job/deploy job/package(s)
					options[:depot_group_name],		# name of group that should contain the new package(s)
					options[:depot_job_group_name]	# name of group that should contain the generated deploy job(s)
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
		
		def self.set_remediation_with_deploy_options(url, session_id, options = {})
			BsaPatch.validate_cli_options_hash([:patching_job_key, :pck_prefix, :depot_group_name, :depot_job_group_name, :deploy_job_key],options)
			db_key_result = BsaPatch.execute_cli_with_param_list(url, session_id, self.name, "setRemediationWithDeployOptions",
				[
					options[:patching_job_key],		# handle to the patching job
					options[:pck_prefix],			# prefix for naming the new batch job/deploy job/package(s)
					options[:depot_group_name],		# name of group that should contain the new package(s)
					options[:depot_job_group_name],	# name of group that should contain the generated deploy job(s)
					options[:deploy_job_key]		# handle to the deploy job run whose options you want to use with
													#  generated deploy job(s)
				])
			db_key = BsaPatch.get_cli_return_value(db_key_result)
		rescue => exception
			raise "#{self.name} Exception: #{exception.to_s}"
		end
	end
#end
