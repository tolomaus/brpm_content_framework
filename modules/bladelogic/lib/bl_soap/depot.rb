require "bladelogic/lib/bl_soap/soap"

class DepotGroup
	def self.create_depot_group(session_id, options = {})
		BsaSoap.validate_cli_options_hash([:group_name, :parent_id], options)
		integer_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "createDepotGroup",
			[
				options[:group_name],	# group name to be created
				options[:parent_id]		# parent id
			])
		integer_value = BsaSoap.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.create_depot_group_with_parent_name(session_id, options = {})
		BsaSoap.validate_cli_options_hash([:group_name, :parent_group_name], options)
		integer_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "createDepotGroupWithParentName",
			[
				options[:group_name],			# group name to be created
				options[:parent_group_name]		# parent group name
			])
		integer_value = BsaSoap.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.group_exists(session_id, options = {})
		BsaSoap.validate_cli_options_hash([:group_name], options)
		boolean_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "groupExists",
			[
				options[:group_name]	# fully qualified group to check
			])
		boolean_value = BsaSoap.get_cli_return_value(boolean_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.group_name_to_id(session_id, options = {})
		BsaSoap.validate_cli_options_hash([:group_name], options)
		integer_result = BsaSoap.execute_cli_with_param_list(session_id, self.name, "groupNameToId",
			[
				options[:group_name],
			])
		integer_value = BsaSoap.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
end