require "ansible/lib/ansible"
require "brpm/lib/brpm_rest_client"

def execute_script(params)
  server_group = get_server_group_from_step_id(params["step_id"])

  execute_ansible_role(params["role"], server_group)
end