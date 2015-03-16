require "bladelogic/lib/bl_soap/soap"

module BsaDepot
	extend BsaSoap
end

class DepotGroup
	def self.create_depot_group(url, session_id, options = {})
		BsaDepot.validate_cli_options_hash([:group_name, :parent_id], options)
		integer_result = BsaDepot.execute_cli_with_param_list(url, session_id, self.name, "createDepotGroup",
			[
				options[:group_name],	# group name to be created
				options[:parent_id]		# parent id
			])
		integer_value = BsaDepot.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.create_depot_group_with_parent_name(url, session_id, options = {})
		BsaDepot.validate_cli_options_hash([:group_name, :parent_group_name], options)
		integer_result = BsaDepot.execute_cli_with_param_list(url, session_id, self.name, "createDepotGroupWithParentName",
			[
				options[:group_name],			# group name to be created
				options[:parent_group_name]		# parent group name
			])
		integer_value = BsaDepot.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.group_exists(url, session_id, options = {})
		BsaDepot.validate_cli_options_hash([:group_name], options)
		boolean_result = BsaDepot.execute_cli_with_param_list(url, session_id, self.name, "groupExists",
			[
				options[:group_name]	# fully qualified group to check
			])
		boolean_value = BsaDepot.get_cli_return_value(boolean_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
	
	def self.group_name_to_id(url, session_id, options = {})
		BsaDepot.validate_cli_options_hash([:group_name], options)
		integer_result = BsaDepot.execute_cli_with_param_list(url, session_id, self.name, "groupNameToId",
			[
				options[:group_name],
			])
		integer_value = BsaDepot.get_cli_return_value(integer_result)
	rescue => exception
		raise "Exception executing #{self.name} function: #{exception.to_s}"
	end
end