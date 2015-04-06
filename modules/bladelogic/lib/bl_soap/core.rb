require "bladelogic/lib/bl_soap/soap"

#
# BsaPatch Module
#
module BsaCoreUtils
	extend BsaSoap
end

class Utility
  def self.export_deploy_script_run(url, session_id, options = {})
    BsaCoreUtils.validate_cli_options_hash([:job_group_name, :job_name, :run_id, :export_file_name], options)
    void_result = BsaCoreUtils.execute_cli_with_attachments(url, session_id, self.name, "exportDeployRun",
      [
          options[:job_group_name],			# fully qualified job group where compliance job is stored
          options[:job_name],					# name of compliance job
          options[:run_id],					# job run id of compliance job
          options[:export_file_name],
      ], nil)
    return void_result[:attachment]
      #void_value = BsaCoreUtils.get_cli_return_value(void_result)
      #return options[:export_file_name]
  rescue => exception
    raise "Error exporting deploy run results: #{exception.to_s}"
  end

	def self.export_deploy_run_status_by_group(url, session_id, options = {})
		BsaCoreUtils.validate_cli_options_hash([:job_group_name, :export_file_name], options)
		void_result = BsaCoreUtils.execute_cli_with_attachments(url, session_id, self.name, "exportDeployRunStatusByGroup",
			[
				options[:job_group_name],					# job run id of compliance job
				options[:export_file_name],
			], nil)
		return void_result[:attachment]
		#void_value = BsaCoreUtils.get_cli_return_value(void_result)
		#return options[:export_file_name]
	rescue => exception
		raise "Error exporting deploy run status results: #{exception.to_s}"
	end

	def self.export_nsh_script_run(url, session_id, options = {})
		BsaCoreUtils.validate_cli_options_hash([:run_id, :export_file_name], options)
		void_result = BsaCoreUtils.execute_cli_with_attachments(url, session_id, self.name, "exportNSHScriptRun",
			[
				options[:run_id],					# job run id of compliance job
				options[:export_file_name],
			], nil)
		return void_result[:attachment]
		#void_value = BsaCoreUtils.get_cli_return_value(void_result)
		#return options[:export_file_name]
	rescue => exception
		raise "Error exporting NSH script run results: #{exception.to_s}"
	end

	def self.export_compliance_run(url, session_id, options = {})
		BsaCoreUtils.validate_cli_options_hash([:job_group_name, :job_name, :run_id, :export_type, :export_file_name], options)
		void_result = BsaCoreUtils.execute_cli_with_attachments(url, session_id, self.name, "exportComplianceRun",
			[
				options[:template_group_name] || "",		# fully qualified template group
				options[:template_name] || "",			# name of component template
				options[:rule_name] || "", 		# fully qualified path of the rule of the compliance job or null for all results
				options[:job_group_name],			# fully qualified job group where compliance job is stored
				options[:job_name],					# name of compliance job
				options[:run_id],					# job run id of compliance job
				options[:export_file_name],
				options[:export_type]
			], nil)
		return void_result[:attachment]
		#void_value = BsaCoreUtils.get_cli_return_value(void_result)
		#return options[:export_file_name]
	rescue => exception
		raise "Error exporting compliance results: #{exception.to_s}"
	end

	def self.export_patch_analysis_run(url, session_id, options = {})
		BsaCoreUtils.validate_cli_options_hash([:job_group_name, :job_name, :run_id, :export_type, :export_file_name], options)
		void_result = BsaCoreUtils.execute_cli_with_attachments(url, session_id, self.name, "exportPatchAnalysisRun",
			[
				options[:Server_name] || "",		# fully qualified template group
				options[:job_group_name],			# fully qualified job group where compliance job is stored
				options[:job_name],					# name of compliance job
				options[:run_id],					# job run id of compliance job
				options[:export_file_name],
				options[:export_type]
			], nil)
		return void_result[:attachment]
		#void_value = BsaCoreUtils.get_cli_return_value(void_result)
		#return options[:export_file_name]
	rescue => exception
		raise "Error exporting patch analysis run results: #{exception.to_s}"
	end
end

# class LogItem
#   def self. get_log_items_by_job_run(url, session_id, options = {})
#     BsaCoreUtils.validate_cli_options_hash([:job_key, :run_id], options)
#     void_result = BsaCoreUtils.execute_cli_with_attachments(url, session_id, self.name, "getLogItemsByJobRun",
#                                                             [
#                                                                 options[:job_key],			# fully qualified job group where compliance job is stored
#                                                                 options[:run_id],					# job run id of compliance job
#                                                             ], nil)
#     return void_result[:attachment]
#       #void_value = BsaCoreUtils.get_cli_return_value(void_result)
#       #return options[:export_file_name]
#   rescue => exception
#     raise "Error exporting deploy run results: #{exception.to_s}"
#   end
# end