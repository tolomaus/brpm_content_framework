# does not support add/remove permissions or ACL, makes no sense in BRPM
# does not support creating job groups
# does not support setting descriptions
class JobGroup < BsaSoapBase
  def create_group_with_parent_name(options = {})
    validate_cli_options_hash([:group_name, :parent_group_name], options)
    integer_result = execute_cli_with_param_list(self.class, "createGroupWithParentName",
                                                 [
                                                     options[:group_name],			# group name to be created
                                                     options[:parent_group_name]		# parent group name
                                                 ])
    integer_value = get_cli_return_value(integer_result)
  rescue => exception
    raise "Exception executing #{self.class} function: #{exception.to_s}"
  end

  def create_job_group(options = {})
    validate_cli_options_hash([:group_name, :parent_id], options)
    integer_result = execute_cli_with_param_list(self.class, "createJobGroup",
                                                 [
                                                     options[:group_name],	# group name to be created
                                                     options[:parent_id]		# parent group id
                                                 ])
    integer_value = get_cli_return_value(integer_result)
  rescue => exception
    raise "Exception executing #{self.class} function: #{exception.to_s}"
  end

  def find_all_groups_by_parent_group_name(options = {})
    validate_cli_options_hash([:job_group], options)
    string_result = execute_cli_with_param_list(self.class, "findAllGroupsByParentGroupName",
                                                [
                                                    options[:job_group]	# Fully qualified parent job group name (/ for root group)
                                                ])
    string_value = get_cli_return_value(string_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def group_exists(options = {})
    validate_cli_options_hash([:group_name], options)
    boolean_result = execute_cli_with_param_list(self.class, "groupExists",
                                                 [
                                                     options[:group_name]	# Fully qualified job group name (/ for root group)
                                                 ])
    boolean_value = get_cli_return_value(boolean_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def group_name_to_db_key(options = {})
    validate_cli_options_hash([:group_name], options)
    db_key_result = execute_cli_with_param_list(self.class, "groupNameToDBKey",
                                                [
                                                    options[:group_name]	# Fully qualified job group name (/ for root group)
                                                ])
    db_key = get_cli_return_value(db_key_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end

  def group_name_to_id(options = {})
    validate_cli_options_hash([:group_name], options)
    integer_result = execute_cli_with_param_list(self.class, "groupNameToId",
                                                 [
                                                     options[:group_name]	# Fully qualified job group name (/ for root group)
                                                 ])
    integer_value = get_cli_return_value(integer_result)
  rescue => exception
    raise "#{self.class} Exception: #{exception.to_s}"
  end
end