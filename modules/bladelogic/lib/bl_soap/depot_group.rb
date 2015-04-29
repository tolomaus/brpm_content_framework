class DepotGroup < BsaSoapBase
	def create_depot_group(options = {})
		validate_cli_options_hash([:group_name, :parent_id], options)
		integer_result = execute_cli_with_param_list(self.class, "createDepotGroup",
																								 [
																										 options[:group_name],	# group name to be created
																										 options[:parent_id]		# parent id
																								 ])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.class} function: #{exception.to_s}"
	end

	def create_depot_group_with_parent_name(options = {})
		validate_cli_options_hash([:group_name, :parent_group_name], options)
		integer_result = execute_cli_with_param_list(self.class, "createDepotGroupWithParentName",
																								 [
																										 options[:group_name],			# group name to be created
																										 options[:parent_group_name]		# parent group name
																								 ])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.class} function: #{exception.to_s}"
	end

	def group_exists(options = {})
		validate_cli_options_hash([:group_name], options)
		boolean_result = execute_cli_with_param_list(self.class, "groupExists",
																								 [
																										 options[:group_name]	# fully qualified group to check
																								 ])
		boolean_value = get_cli_return_value(boolean_result)
	rescue => exception
		raise "Exception executing #{self.class} function: #{exception.to_s}"
	end

	def group_name_to_id(options = {})
		validate_cli_options_hash([:group_name], options)
		integer_result = execute_cli_with_param_list(self.class, "groupNameToId",
																								 [
																										 options[:group_name]	# Fully qualified path
																								 ])
		integer_value = get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.class} function: #{exception.to_s}"
	end
end