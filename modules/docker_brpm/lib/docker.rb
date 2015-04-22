def get_docker_server_name
  "Docker"
end

def get_docker_host_name
  @docker_host_name ||= get_server_list($params)[get_docker_server_name]["dns"]
end

def run_docker_command(command, ignore_error=false)
  complete_command = "docker -H tcp://#{get_docker_host_name()}:4243 #{command} 2>&1"

  BrpmAuto.log complete_command
  output = `#{complete_command}`
  BrpmAuto.log "\toutput: #{output}"

  exit_status = $?.exitstatus
  unless exit_status == 0
    message = "The docker command exited with #{exit_status}."
    if ignore_error
      BrpmAuto.log "\t#{message}"
    else
      raise(message)
    end
  end

  output
end

def run_docker_command_and_ignore_error(command)
  run_docker_command(command, true)
end

def stop_running_containers_if_necessary(container_names_to_be_stopped)
  container_names_to_be_stopped.each do |container_name|
    BrpmAuto.log "Stopping and removing container #{container_name} ..."
    run_docker_command("stop #{container_name}", true)
    run_docker_command("rm #{container_name}", true)
  end
end
