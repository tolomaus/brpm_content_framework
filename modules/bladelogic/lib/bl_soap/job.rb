# Does not support Schedule manipulation, makes no sense in BRPM situation
# Does not support ACL or permission manipulation, makes no sense in BRPM situation
# Does not support Bulk property configuration
# Does not support Moving or Copy of Jobs
# Does not support Removing properties
class Job < BsaSoapBase
	def add_target_component_group(options = {})
		validate_cli_options_hash([:job_key, :group_name], options)
		db_key_result = execute_cli_with_param_list(self.class, "addTargetComponentGroup",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_name]	# Name of the component server group
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def add_target_group(options = {})
		validate_cli_options_hash([:job_key, :group_name], options)
		db_key_result = execute_cli_with_param_list(self.class, "addTargetGroup",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_name]	# Name of the server group
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def add_target_groups(options = {})
		validate_cli_options_hash([:job_key, :group_names], options)
		db_key_result = execute_cli_with_param_list(self.class, "addTargetGroups",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_names]	# Name of the groups to add (comma separated list)
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def add_target_server(options = {})
		validate_cli_options_hash([:job_key, :server_name], options)
		db_key_result = execute_cli_with_param_list(self.class, "addTargetServer",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_name]	# Name of the server to add
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def add_target_servers(options = {})
		validate_cli_options_hash([:job_key, :server_names], options)
		db_key_result = execute_cli_with_param_list(self.class, "addTargetServers",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_names]	# Name of the servers to add (comma separated list)
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def clear_target_group(options = {})
		validate_cli_options_hash([:job_key, :group_name], options)
		db_key_result = execute_cli_with_param_list(self.class, "clearTargetGroup",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_name]	# Name of the server group
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def clear_target_groups(options = {})
		validate_cli_options_hash([:job_key], options)
		db_key_result = execute_cli_with_param_list(self.class, "clearTargetGroups",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def clear_target_server(options = {})
		validate_cli_options_hash([:job_key, :server_name], options)
		db_key_result = execute_cli_with_param_list(self.class, "clearTargetServer",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_name]	# Name of the server to add
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def clear_target_servers(options = {})
		validate_cli_options_hash([:job_key], options)
		db_key_result = execute_cli_with_param_list(self.class, "clearTargetServers",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def create_approval(options = {})
		validate_cli_options_hash([:approval_type, :change_type, :impact_id, :risk_level], options)
		integer_result = execute_cli_with_param_list(self.class, "createApproval",
			[
				options[:approval_type],	# The approval type
				options[:change_type],		# The change type
				options[:comments] || "",	# A string that appears in the change summary (if approval_type = 5, change can be "")
				options[:impact_id],		# The impact id
				options[:risk_level],		# The risk level
				options[:change_id] || "",	# The change id from the change management system (only if approval_type = 5) 
				options[:task_id] || ""		# The task id from the change management system ( only if approval_type = 5)
			])
			integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute(options = {})
		validate_cli_options_hash([:job_key], options)
		void_result = execute_cli_with_param_list(self.class, "execute",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		void_value = get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_against_component_groups(options = {})
		validate_cli_options_hash([:job_key, :group_names], options)
		integer_result = execute_cli_with_param_list(self.class, "executeAgainstComponentGroups",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_names]	# Name of component group(s) - comma-separated list of group names
			])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_against_component_groups_for_run_id(options = {})
		validate_cli_options_hash([:job_key, :group_names], options)
		job_run_key_result = execute_cli_with_param_list(self.class, "executeAgainstComponentGroupsForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_names]	# Name of component group(s) - comma-separated list of group names
			])
		job_run_key = get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_against_failed_target(options = {})
		validate_cli_options_hash([:job_key, :filter_type], options)
		integer_result = execute_cli_with_param_list(self.class, "executeAgainstFailedTarget",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:filter_type]	# The failure level of the targets you want to execute against
			])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_against_server_groups(options = {})
		validate_cli_options_hash([:job_key, :server_groups], options)
		integer_result = execute_cli_with_param_list(self.class, "executeAgainstServerGroups",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_groups]	# Name of server group(s) - comma-separated list of group names
			])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_against_server_groups_for_run_id(options = {})
		validate_cli_options_hash([:job_key, :server_groups], options)
		job_run_key_result = execute_cli_with_param_list(self.class, "executeAgainstServerGroupsForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_groups]	# Name of server group(s) - comma-separated list of group names
			])
		job_run_key = get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_against_servers(options = {})
		validate_cli_options_hash([:job_key, :server_names], options)
		integer_result = execute_cli_with_param_list(self.class, "executeAgainstServers",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_names]	# Name of server group(s) - comma-separated list of group names
			])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_against_servers_for_run_id(options = {})
		validate_cli_options_hash([:job_key, :server_names], options)
		job_run_key_result = execute_cli_with_param_list(self.class, "executeAgainstServersForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_names]	# Name of server group(s) - comma-separated list of group names
			])
		job_run_key = get_cli_return_value(job_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_job_and_wait(options = {})
		validate_cli_options_hash([:job_key], options)
		job_run_key_result = execute_cli_with_param_list(self.class, "executeJobAndWait",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		job_run_key = get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end

	def execute_job_and_wait_for_run_id(options = {})
		validate_cli_options_hash([:job_key], options)
		job_run_key_result = execute_cli_with_param_list(self.class, "executeJobAndWaitForRunID",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		job_run_key = get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end

	def execute_job_with_approval_and_wait_for_run_id(options = {})
		validate_cli_options_hash([:job_key, :approval_id], options)
		job_run_key_result = execute_cli_with_param_list(self.class, "executeJobWithApprovalAndWaitForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:approval_id]	# Approval id
			])
		job_run_key = get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def execute_with_approval(options = {})
		validate_cli_options_hash([:job_key, :approval_id], options)
		void_result = execute_cli_with_param_list(self.class, "executeJobWithApprovalAndWaitForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:approval_id]	# Approval id
			])
		void_value = get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def get_group_id(options = {})
		validate_cli_options_hash([:job_key], options)
		integer_result = execute_cli_with_param_list(self.class, "getGroupId",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def get_job_name_by_db_key(options = {})
		validate_cli_options_hash([:job_db_key], options)
		string_result = execute_cli_with_param_list(self.class, "getJobNameByDBKey",
			[
				options[:job_db_key]	# Handle of the job
			])
		string_value = get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def get_last_job_db_key_by_job_id(options = {})
		validate_cli_options_hash([:job_id], options)
		db_key_result = execute_cli_with_param_list(self.class, "getLastJobDBKeyByJobId",
			[
				options[:job_id]	# Handle of the job
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def get_target_servers(options = {})
		validate_cli_options_hash([:job_key, :server_state], options)
		list_result = execute_cli_with_param_list(self.class, "getTargetServers",
			[
				options[:job_key],		# Handle of the job
				options[:server_state]	# desired server states
			])
		list_value = get_cli_return_value(list_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def get_targets(options = {})
		validate_cli_options_hash([:job_key, :taret_types], options)
		list_result = execute_cli_with_param_list(self.class, "getTargets",
			[
				options[:job_key],		# Handle of the job
				options[:target_types]	# desired target types
			])
		list_value = get_cli_return_value(list_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def list_all_by_group(options = {})
		validate_cli_options_hash([:group_name], options)
		string_result = execute_cli_with_param_list(self.class, "listAllByGroup",
			[
				options[:group_name]	# Fully qualified group name
			])
		string_value = get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def set_max_parallelism(options = {})
		validate_cli_options_hash([:job_key, :parallelism], options)
		db_key_result = execute_cli_with_param_list(self.class, "setMaxParallelism",
			[
				options[:job_key],		# Handle of the job
				options[:parallelism]	# max parallelism
			])
		db_key = get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
	
	def set_property_value(options = {})
		validate_cli_options_hash([:object_key, :property_name, :value_as_string], options)
		job_id_result = execute_cli_with_param_list(self.class, "getTargets",
			[
				options[:object_key],		# DBKey of the job
				options[:property_name],	# property name
				options[:value_as_string]	# property value
			])
		job_id = get_cli_return_value(job_id_result)
	rescue => exception
		raise "#{self.class} Exception: #{exception.to_s}"
	end
end













