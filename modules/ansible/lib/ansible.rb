def execute_ansible_role(role, server_group, ignore_error=false)
  playbook_file_path = "/home/ansib/playbook_#{server_group}_#{role}_#{Time.now.strftime("%Y%m%d%H%M%S")}.yml"
  playbook_content = <<EOF
---
# Make sure the facts of all servers are available for the role to be applied
- hosts: all
  tasks: []

- hosts: #{server_group}
  sudo: True
  roles:
  - #{role}
EOF

  BrpmAuto.log "Creating playbook.yml..."
  file = File.open(playbook_file_path, 'w') {|f| f.write(playbook_content) }

  complete_command = "su ansib -c \"ansible-playbook #{playbook_file_path}\" 2>&1"

  BrpmAuto.log complete_command
  output = `#{complete_command}`
  BrpmAuto.log "\toutput: #{output}"

  File.delete(playbook_file_path)

  exit_status = $?.exitstatus
  unless exit_status == 0
    message = "The command exited with #{exit_status}."
    if ignore_error
      BrpmAuto.log "\t#{message}"
    else
      raise(message)
    end
  end

  output
end

def execute_ansible_role_and_ignore_error(command)
  execute_ansible_role(command, true)
end
