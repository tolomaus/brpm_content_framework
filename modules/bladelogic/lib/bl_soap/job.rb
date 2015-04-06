require "bladelogic/lib/bl_soap/soap"

#
# BsaJob
#
# Full Support: Job, JobGroup, JobManagement, JobResult, JobRun
# Some Support: DeployJob, DepotGroup
# Future Support: DeployJobRun, DepotFile, DepotObject, DepotSoftware
# Possible Support: All other Jobs (NSH, FIle, Batch, BL, etc.)
#
# Also might break up to smaller units
#
module BsaJob
	extend BsaSoap
end

# Does not support Schedule manipulation, makes no sense in BRPM situation
# Does not support ACL or permission manipulation, makes no sense in BRPM situation
# Does not support Bulk property configuration
# Does not support Moving or Copy of Jobs
# Does not support Removing properties
class Job
	def self.add_target_component_group(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :group_name], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "addTargetComponentGroup",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_name]	# Name of the component server group
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.add_target_group(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :group_name], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "addTargetGroup",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_name]	# Name of the server group
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.add_target_groups(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :group_names], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "addTargetGroups",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_names]	# Name of the groups to add (comma separated list)
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.add_target_server(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :server_name], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "addTargetServer",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_name]	# Name of the server to add
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.add_target_servers(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :server_names], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "addTargetServers",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_names]	# Name of the servers to add (comma separated list)
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.clear_target_group(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :group_name], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "clearTargetGroup",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_name]	# Name of the server group
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.clear_target_groups(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "clearTargetGroups",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.clear_target_server(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :server_name], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "clearTargetServer",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_name]	# Name of the server to add
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.clear_target_servers(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "clearTargetServers",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.create_approval(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:approval_type, :change_type, :impact_id, :risk_level], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "createApproval",
			[
				options[:approval_type],	# The approval type
				options[:change_type],		# The change type
				options[:comments] || "",	# A string that appears in the change summary (if approval_type = 5, change can be "")
				options[:impact_id],		# The impact id
				options[:risk_level],		# The risk level
				options[:change_id] || "",	# The change id from the change management system (only if approval_type = 5) 
				options[:task_id] || ""		# The task id from the change management system ( only if approval_type = 5)
			])
			integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "execute",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_against_component_groups(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :group_names], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeAgainstComponentGroups",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_names]	# Name of component group(s) - comma-separated list of group names
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_against_component_groups_for_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :group_names], options)
		job_run_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeAgainstComponentGroupsForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:group_names]	# Name of component group(s) - comma-separated list of group names
			])
		job_run_key = BsaJob.get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_against_failed_target(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :filter_type], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeAgainstFailedTarget",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:filter_type]	# The failure level of the targets you want to execute against
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_against_server_groups(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :server_groups], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeAgainstServerGroups",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_groups]	# Name of server group(s) - comma-separated list of group names
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_against_server_groups_for_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :server_groups], options)
		job_run_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeAgainstServerGroupsForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_groups]	# Name of server group(s) - comma-separated list of group names
			])
		job_run_key = BsaJob.get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_against_servers(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :server_names], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeAgainstServers",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_names]	# Name of server group(s) - comma-separated list of group names
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_against_servers_for_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :server_names], options)
		job_run_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeAgainstServersForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:server_names]	# Name of server group(s) - comma-separated list of group names
			])
		job_run_key = BsaJob.get_cli_return_value(job_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_job_and_wait(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		job_run_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeJobAndWait",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		job_run_key = BsaJob.get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end

	def self.execute_job_and_wait_for_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		job_run_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeJobAndWaitForRunID",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		job_run_key = BsaJob.get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end

	def self.execute_job_with_approval_and_wait_for_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :approval_id], options)
		job_run_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeJobWithApprovalAndWaitForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:approval_id]	# Approval id
			])
		job_run_key = BsaJob.get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.execute_with_approval(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :approval_id], options)
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeJobWithApprovalAndWaitForRunID",
			[
				options[:job_key],		# Handle of the job to be updated
				options[:approval_id]	# Approval id
			])
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_group_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getGroupId",
			[
				options[:job_key]	# Handle of the job to be updated
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_job_name_by_db_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_db_key], options)
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getJobNameByDBKey",
			[
				options[:job_db_key]	# Handle of the job
			])
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_last_job_db_key_by_job_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_id], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getLastJobDBKeyByJobId",
			[
				options[:job_id]	# Handle of the job
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_target_servers(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :server_state], options)
		list_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getTargetServers",
			[
				options[:job_key],		# Handle of the job
				options[:server_state]	# desired server states
			])
		list_value = BsaJob.get_cli_return_value(list_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_targets(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :taret_types], options)
		list_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getTargets",
			[
				options[:job_key],		# Handle of the job
				options[:target_types]	# desired target types
			])
		list_value = BsaJob.get_cli_return_value(list_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.list_all_by_group(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name], options)
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "listAllByGroup",
			[
				options[:group_name]	# Fully qualified group name
			])
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.set_max_parallelism(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :parallelism], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "setMaxParallelism",
			[
				options[:job_key],		# Handle of the job
				options[:parallelism]	# max parallelism
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.set_property_value(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:object_key, :property_name, :value_as_string], options)
		job_id_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getTargets",
			[
				options[:object_key],		# DBKey of the job
				options[:property_name],	# property name
				options[:value_as_string]	# property value
			])
		job_id = BsaJob.get_cli_return_value(job_id_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
end

class PatchRemediationJob
  def self.execute_job_and_wait(url, session_id, options = {})
    BsaJob.validate_cli_options_hash([:job_key], options)
    job_run_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "executeJobAndWait",
                                                            [
                                                                options[:job_key]	# Handle of the job to be updated
                                                            ])
    job_run_key = BsaJob.get_cli_return_value(job_run_key_result)
  rescue => exception
    raise "#{self.name} Exception: #{exception.to_s}"
  end
end
# does not support add/remove permissions or ACL, makes no sense in BRPM
# does not support creating job groups
# does not support setting descriptions
class JobGroup
	def self.create_group_with_parent_name(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name, :parent_group_name], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "createGroupWithParentName",
			[
				options[:group_name],			# group name to be created
				options[:parent_group_name]		# parent group name
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.create_job_group(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name, :parent_id], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "createJobGroup",
			[
				options[:group_name],	# group name to be created
				options[:parent_id]		# parent group id
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.find_all_groups_by_parent_group_name(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_group], options)
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "findAllGroupsByParentGroupName",
			[
				options[:job_group]	# Fully qualified parent job group name (/ for root group)
			])
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.group_exists(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name], options)
		boolean_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "groupExists",
			[
				options[:group_name]	# Fully qualified job group name (/ for root group)
			])
		boolean_value = BsaJob.get_cli_return_value(boolean_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.group_name_to_db_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "groupNameToDBKey",
			[
				options[:group_name]	# Fully qualified job group name (/ for root group)
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.group_name_to_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "groupNameToId",
			[
				options[:group_name]	# Fully qualified job group name (/ for root group)
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
end

class JobManagement
	def self.get_job_manager_full_status(url, session_id, options = {})
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getJobManagerFullStatus")
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_job_manager_status(url, session_id, options = {})
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getJobManagerStatus")
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_running_jobs_status(url, session_id, options = {})
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getRunningJobsStatus")
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
end

class JobResult
	def self.find_job_result_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		job_run_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "findJobResultKey",
			[
				options[:job_run_key]	# Handle associated with a particular job run
			])
		job_run_key = BsaJob.get_cli_return_value(job_run_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
end

class JobRun
	def self.change_priority_of_running_job_by_job_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_id, :priority_string], options)
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "changePriorityOfRunningJobByJobRunId",
			[
				options[:job_run_id],		# Job run ID number
				options[:priority_string]	# Priority to change job run to
			])
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.find_all_run_keys_by_job_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "findAllRunKeysByJobKey",
			[
				options[:job_key]	# DBKey key for the job
			])
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.find_last_run_key_by_job_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "findLastRunKeyByJobKey",
			[
				options[:job_key],							# DBKey for the job
				# NIEK options[:exclude_deploy_attempts] || false	# Exclude deploy attempt run id
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
		
	def self.find_last_run_key_by_job_key_ignore_version(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "findLastRunKeyByJobKeyIgnoreVersion",
			[
				options[:job_key]	# DBKey for the job
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.find_run_count_by_job_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "findRunCountByJobKey",
			[
				options[:job_key]	# DBKey for the job
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.find_run_key_by_id(url, session_id, options = {})
		#findRunKeyById_1 is deprecated => No support for job_key option
		BsaJob.validate_cli_options_hash([:job_run_id], options)
		db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "findRunKeyById",
			[
				options[:job_run_id]	# Run number of the job run
			])
		db_key = BsaJob.get_cli_return_value(db_key_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_aborted_job_runs_by_end_date(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:end_type], options)
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getAbortedJobRunsByEndDate",
			[
				options[:end_time]	# Time to use as the earliest end date, only runs aborted after this date will be shown
			])
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_end_time_by_run_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		object_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getEndTimeByRunKey",
			[
				options[:job_run_key],						# Handle identifying a particular job run
				options[:format] || "yyyy/MM/dd HH:mm:ss"	# Format for presenting time
			])
		object_value = BsaJob.get_cli_return_value(object_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_executing_user_and_role_by_run_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getExecutingUserAndRoleByRunKey",
			[
				options[:job_run_key]	# Handle identifying a particular job run
			])
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_job_run_had_errors(url, session_id, options = {})
		# getJobRunHadErrors_1 deprecated => No support
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		boolean_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getJobRunHadErrors",
			[
				options[:job_run_key]	# Handle identifying a particular job run
			])
		boolean_value = BsaJob.get_cli_return_value(boolean_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_job_run_had_errors_by_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_id], options)
		boolean_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getJobRunHadErrorsById",
			[
				options[:job_run_id]	# Run ID for the job run
			])
		boolean_value = BsaJob.get_cli_return_value(boolean_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_job_run_is_running_by_run_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		boolean_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getJobRunIsRunningByRunKey",
			[
				options[:job_run_key]	# Handle identifying a particular job run
			])
		boolean_value = BsaJob.get_cli_return_value(boolean_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_job_run_status_by_schedule_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:schedule_id], options)
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getJobRunStatusByScheduleId",
			[
				options[:schedule_id]	# Handle identifying a particular job run
			])
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_log_items_by_job_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_key, :job_run_id], options)
		string_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getLogItemsByJobRunId",
			[
				options[:job_key],		# DB Key of the job
				options[:job_run_id]	# Job run ID number
			])
		string_value = BsaJob.get_cli_return_value(string_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_servers_status_by_job_run(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_id], options)
		map_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getServerStatusByJobRun",
			[
				options[:job_run_id]	# Job run ID number
			])
		map_value = BsaJob.get_cli_return_value(map_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.get_start_time_by_run_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		object_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getStartTimeByRunKey",
			[
				options[:job_run_key],						# Handle identifying a particular job run
				options[:format] || "yyyy/MM/dd HH:mm:ss"	# Format for presenting time
			])
		object_value = BsaJob.get_cli_return_value(object_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.job_run_key_to_job_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "jobRunKeyToJobRunId",
			[
				options[:job_run_key]	# Handle identifying a particular job run
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.pause_running_job_by_job_run_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "pauseRunningJobByJobRunKey",
			[
				options[:job_run_key]	# Handle identifying a particular job run
			])
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.resume_paused_job_by_job_run_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "resumePausedJobByJobRunKey",
			[
				options[:job_run_key]	# Handle identifying a particular job run
			])
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.show_all_running_batch_job_run_status(url, session_id, options = {})
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "showAllRunningBatchJobRunStatus")
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.show_all_running_post_prov_batch_job_run_status(url, session_id, options = {})
		list_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "showAllRunningPostProvBatchJobRunStatus")
		list_value = BsaJob.get_cli_return_value(list_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.show_batch_job_run_status_by_run_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:run_id], options)
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "showBatchJobRunStatusByRunId",
			[
				options[:run_id]	# Handle identifying a particular job run
			])
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.show_batch_job_run_status_by_run_key(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:job_run_key], options)
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "showBatchJobRunStatusByRunId",
			[
				options[:job_run_key]	# Handle identifying a particular job run
			])
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end
	
	def self.show_running_jobs(url, session_id, options = {})
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "showRunningJobs")
		void_value = BsaJob.get_cli_return_value(void_result)
	rescue => exception
		raise "#{self.name} Exception: #{exception.to_s}"
	end

	def self.get_deploy_job_max_run_id(url, session_id, options = {})
    BsaJob.validate_cli_options_hash([:db_key_of_deploy_job], options)
		void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getDeployJobMaxRunId",
    [
        options[:db_key_of_deploy_job]	# Handle identifying a particular job run
    ])
    void_value = BsaJob.get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.name} Exception: #{exception.to_s}"
  end
end

# very basic support right now
class DeployJob
  def self.create_deploy_job(url, session_id, options = {})
    BsaJob.validate_cli_options_hash([:job_name, :group_id, :package_db_key, :server_name], options)
    db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "createDeployJob",
      [
          options[:job_name],
          options[:group_id],
          options[:package_db_key],
          options[:server_name],
          true, #isSimulateEnabled
          true, #isCommitEnabled
          false, #isStagedIndirect
      ])
    db_key = BsaJob.get_cli_return_value(db_key_result)
  rescue => exception
    raise "Exception executing #{self.name} function: #{exception.to_s}"
  end

  def self.get_dbkey_by_group_and_name(url, session_id, options = {})
    BsaJob.validate_cli_options_hash([:group_name, :job_name], options)
    db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getDBKeyByGroupAndName",
                                                       [
                                                           options[:group_name],	# Fully qualified path to the job group containing the job
                                                           options[:job_name]		# Name of the job
                                                       ])
    db_key = BsaJob.get_cli_return_value(db_key_result)
  rescue => exception
    raise "Exception executing #{self.name} function: #{exception.to_s}"
  end

  def self.set_phase_schedule_by_dbkey(url, session_id, options = {})
    BsaJob.validate_cli_options_hash([:job_run_key], options)
    void_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "setAdvanceDeployJobPhaseScheduleByDBKey",
                                                     [
                                                         options[:job_run_key],
                                                         options[:simulate_type],
                                                         options[:simulate_date],
                                                         options[:stage_type],
                                                         options[:stage_date],
                                                         options[:commit_type],
                                                         options[:commit_date],
                                                     ])
    void_value = BsaJob.get_cli_return_value(void_result)
  rescue => exception
    raise "#{self.name} Exception: #{exception.to_s}"
  end
end

# very basic support right now
class NSHScriptJob
  def self.get_dbkey_by_group_and_name(url, session_id, options = {})
    BsaJob.validate_cli_options_hash([:group_name, :job_name], options)
    db_key_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "getDBKeyByGroupAndName",
                                                       [
                                                           options[:group_name],	# Fully qualified path to the job group containing the job
                                                           options[:job_name]		# Name of the job
                                                       ])
    db_key = BsaJob.get_cli_return_value(db_key_result)
  rescue => exception
    raise "Exception executing #{self.name} function: #{exception.to_s}"
  end
end

class DepotGroup
	def self.create_depot_group(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name, :parent_id], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "createDepotGroup",
			[
				options[:group_name],	# group name to be created
				options[:parent_id]		# parent id
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.create_depot_group_with_parent_name(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name, :parent_group_name], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "createDepotGroupWithParentName",
			[
				options[:group_name],			# group name to be created
				options[:parent_group_name]		# parent group name
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.group_exists(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name], options)
		boolean_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "groupExists",
			[
				options[:group_name]	# fully qualified group to check
			])
		boolean_value = BsaJob.get_cli_return_value(boolean_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.group_name_to_id(url, session_id, options = {})
		BsaJob.validate_cli_options_hash([:group_name], options)
		integer_result = BsaJob.execute_cli_with_param_list(url, session_id, self.name, "groupNameToId",
			[
				options[:group_name]	# Fully qualified path
			])
		integer_value = BsaJob.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
end