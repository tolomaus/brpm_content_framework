require "bladelogic/lib/bl_soap/soap"

#
# BsaPatch Module
#
module BsaCompliance
	extend BsaSoap
end

class ComplianceJob
	def self.add_omponent_to_job_by_job_db_key(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash([:compliance_key, :component_key], options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "addComponentToJobByJobDBKey",
			[
				options[:compliance_key],	# Handle to compliance Job
				options[:component_key]		# Handle to component to be added
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)	
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.add_named_server_to_job_by_job_db_key(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash([:db_key, :server_name], options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "addNamedServerToJobByJobDBKey",
			[
				options[:db_key],		# Handle to the Compliance Job
				options[:server_name]	# Name of the server to be added
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.create_component_based_compliance_job(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash([:job_name, :group_id, :template_key, :server_name], options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "createComponentBasedComplianceJob",
			[
				options[:job_name],				# Name of the job to be created
				options[:group_id],				# Id of the parent job group for the compliance job
				options[:template_key],			# Handle to template describing the assets to be included in compliance
				options[:server_name],			# Target server for compliance job
				options[:component_index] || 0	# Index of component on target server (typically 0)
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.create_remediation_job_from_compliance_result_by_rule(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash(
			[:remediation_name, :job_group_name, :depot_group_name, :comp_job_key, :comp_job_run_id, :template_group_name, :template_name, :rule_grp_name, :rule_name, :target_component],
			options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "createRemediationJobFromComplianceResultByRule",
			[
				options[:remediation_name],							# Name of the package
				options[:job_group_name],							# Name of a group that should contain the new remediation job(s)
				options[:depot_group_name],							# Name of a group that should contain the new package(s)
				options[:comp_job_key],								# Handle to compliance job whose job run result you want to package
				options[:comp_job_run_id],							# ID of the compliance job run whose result you want to package
				options[:template_group_name],						# Group name of the template used in the compliance job run
				options[:template_name],							# Name of the template used in the compliance job run
				options[:rule_grp_name],							# Name of the template rule group used in the compliance job run
				options[:rule_name],								# Name of the template rule used in the compliance job run
				options[:target_component],							# Name of the target component
				options[:use_component_device_for_targets] || true,	# Use the device of a component as the target of the remediation (defualt = true) devices are targets
				options[:keep_unique_package_props] || true			# Indicates if the package should uniquely save each local property for the compliance rule packages that are used
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.create_remediation_job_from_compliance_result_by_server(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash(
			[:remediation_name, :job_group_name, :depot_group_name, :comp_job_key, :comp_job_run_id, :target_server, :template_group_name, :template_name, :target_component, :rule_grp_name, :rule_name], 
			options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "createRemediationJobFromComplianceResultByServer",
			[
				options[:remediation_name],							# Name of the package
				options[:job_group_name],							# Name of a group that should contain the new remediation job(s)
				options[:depot_group_name],							# Name of a group that should contain the new package(s)
				options[:comp_job_key],								# Handle to compliance job whose job run result you want to package
				options[:comp_job_run_id],							# ID of the compliance job run whose result you want to package
				options[:target_server],							# Name of the target server
				options[:template_group_name],						# Group name of the template used in the compliance job run
				options[:template_name],							# Name of the template used in the compliance job run
				options[:target_component],							# Name of the target component
				options[:rule_grp_name],							# Name of the template rule group used in the compliance job run
				options[:rule_name],								# Name of the template rule used in the compliance job run
				options[:use_component_device_for_targets] || true,	# Use the device of a component as the target of the remediation (defualt = true) devices are targets
				options[:keep_unique_package_props] || true			# Indicates if the package should uniquely save each local property for the compliance rule packages that are used
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end

	def self.create_template_fltered_compliance_job(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash([:job_name, :group_id, :template_key, :server_name], options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "createTemplateFilteredComplianceJob",
			[
				options[:job_name],		# Name of the job to be created
				options[:group_id],		# Id of the parent job group for the compliance job
				options[:template_key],	# Handle to the template describing the assets to be including in the compliance job
				options[:server_name]	# Target server for the compliance job
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.execute_job_and_wait(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash([:job_key], options)
		job_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "executeJobAndWait",
			[
				options[:job_key]	# Handle to the compliance job to be executed
			])
		job_key = BsaCompliance.get_cli_return_value(job_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.get_dbkey_by_group_and_name(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash([:group_name, :job_name], options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "getDBKeyByGroupAndName",
			[
				options[:group_name],	# Fully qualified path to the job group containing the job
				options[:job_name]		# Name of the job
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.set_auto_remediation(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash([:job_key, :job_name, :depot_group, :job_group], options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "setAutoRemediation",
			[
				options[:job_key],									# Handle to compliance job
				options[:job_name],									# Name for auto-remediation job
				options[:depot_group],								# Name of the depot group to store files in
				options[:job_group],								# Name of the job group to store the remediation job in
				options[:is_auto_remediate] || true,				# Auto-remediation state for the job - true = set
				options[:use_component_device_for_targets] || true,	# Use the device of a component as the target of the remediation (defualt = true) devices are targets
				options[:keep_unique_package_props] || true			# Indicates if the package should uniquely save each local property for the compliance rule packages that are used
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.set_description(url, session_id, options = {})
		BsaCompliance.validate_cli_options_hash([:job_key, :desc], options)
		db_key_result = BsaCompliance.execute_cli_with_param_list(url, session_id, self.name, "setDescription",
			[
				options[:job_key],	# handle to compliance job
				options[:desc]		# description of job
			])
		db_key = BsaCompliance.get_cli_return_value(db_key_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
end