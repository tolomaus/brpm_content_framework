require "framework/lib/request_params"

def execute_script(params)
  add_request_param_unless_exist("input_billing_cost_center", params["Billing Cost Center"])
  add_request_param_unless_exist("input_application_on_call_group", params["Application On Call Group"])
  add_request_param_unless_exist("input_change_management_approver_groups", params["Change Management Approver Groups"])
  add_request_param_unless_exist("input_support_tier", params["Support Tier"])
  add_request_param_unless_exist("input_server_classification", params["Server Classification"])
  add_request_param_unless_exist("input_dr_rating", params["DR Rating"])
  add_request_param_unless_exist("input_backup_required", params["Backup Required?"])
  add_request_param_unless_exist("input_name", params["Name"])
  add_request_param_unless_exist("input_description", params["Description"])
  add_request_param_unless_exist("input_save_in", params["Save in"])
  add_request_param_unless_exist("input_virtual_guest_package", params["Virtual Guest Package"])
  add_request_param_unless_exist("input_target_for_virtual_guest", params["Target for Virtual Guest"])
  add_request_param_unless_exist("input_post_provisioning", params["Post-Provisioning"])
  add_request_param_unless_exist("input_virtual_machine_name", params["Virtual Machine Name"])
  add_request_param_unless_exist("input_processors", params["Processors"])
  add_request_param_unless_exist("input_memory", params["Memory"])
  add_request_param_unless_exist("input_network", params["Network"])
  add_request_param_unless_exist("input_network_storage", params["Network Storage"])
  add_request_param_unless_exist("input_am_application", params["Application"])
  add_request_param_unless_exist("input_am_component", params["Component"])
  add_request_param_unless_exist("input_am_environment", params["Environment"])
end


