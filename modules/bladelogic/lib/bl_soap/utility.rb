class Utility < BsaSoapBase
  def export_deploy_script_run(options = {})
    validate_cli_options_hash([:job_group_name, :job_name, :run_id, :export_file_name], options)
    void_result = execute_cli_with_attachments(self.class, "exportDeployRun",
      [
          options[:job_group_name],			# fully qualified job group where compliance job is stored
          options[:job_name],					# name of compliance job
          options[:run_id],					# job run id of compliance job
          options[:export_file_name],
      ], nil)
    return void_result[:attachment]
      #void_value = BsaSoap.get_cli_return_value(void_result)
      #return options[:export_file_name]
  rescue => exception
    raise "Error exporting deploy run results: #{exception.to_s}"
  end

	def export_deploy_run_status_by_group(options = {})
		validate_cli_options_hash([:job_group_name, :export_file_name], options)
		void_result = execute_cli_with_attachments(self.class, "exportDeployRunStatusByGroup",
			[
				options[:job_group_name],					# job run id of compliance job
				options[:export_file_name],
			], nil)
		return void_result[:attachment]
		#void_value = BsaSoap.get_cli_return_value(void_result)
		#return options[:export_file_name]
	rescue => exception
		raise "Error exporting deploy run status results: #{exception.to_s}"
	end

	def export_nsh_script_run(options = {})
		validate_cli_options_hash([:run_id, :export_file_name], options)
		void_result = execute_cli_with_attachments(self.class, "exportNSHScriptRun",
			[
				options[:run_id],					# job run id of compliance job
				options[:export_file_name],
			], nil)
		return void_result[:attachment]
		#void_value = BsaSoap.get_cli_return_value(void_result)
		#return options[:export_file_name]
	rescue => exception
		raise "Error exporting NSH script run results: #{exception.to_s}"
	end

	def export_compliance_run(options = {})
		validate_cli_options_hash([:job_group_name, :job_name, :run_id, :export_type, :export_file_name], options)
		void_result = execute_cli_with_attachments(self.class, "exportComplianceRun",
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
		#void_value = BsaSoap.get_cli_return_value(void_result)
		#return options[:export_file_name]
	rescue => exception
		raise "Error exporting compliance results: #{exception.to_s}"
	end

	def export_patch_analysis_run(options = {})
		validate_cli_options_hash([:job_group_name, :job_name, :run_id, :export_type, :export_file_name], options)
		void_result = execute_cli_with_attachments(self.class, "exportPatchAnalysisRun",
			[
				options[:Server_name] || "",		# fully qualified template group
				options[:job_group_name],			# fully qualified job group where compliance job is stored
				options[:job_name],					# name of compliance job
				options[:run_id],					# job run id of compliance job
				options[:export_file_name],
				options[:export_type]
			], nil)
		return void_result[:attachment]
		#void_value = BsaSoap.get_cli_return_value(void_result)
		#return options[:export_file_name]
	rescue => exception
		raise "Error exporting patch analysis run results: #{exception.to_s}"
	end
end

# class LogItem
#   def  get_log_items_by_job_run(options = {})
#     BsaSoap.validate_cli_options_hash([:job_key, :run_id], options)
#     void_result = BsaSoap.execute_cli_with_attachments(self.class, "getLogItemsByJobRun",
#                                                             [
#                                                                 options[:job_key],			# fully qualified job group where compliance job is stored
#                                                                 options[:run_id],					# job run id of compliance job
#                                                             ], nil)
#     return void_result[:attachment]
#       #void_value = BsaSoap.get_cli_return_value(void_result)
#       #return options[:export_file_name]
#   rescue => exception
#     raise "Error exporting deploy run results: #{exception.to_s}"
#   end
# end