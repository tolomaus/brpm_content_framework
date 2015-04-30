request_params = BrpmAuto.request_params

pack_response "url", "http://#{get_docker_host_name}:#{request_params["port"]}/brpm"

table_data = []

output = run_docker_command("ps -q")

BrpmAuto.log output

containers = output.split("\n")

table_data << ["?", "ID", "Name", "Created"]
containers.each do |container_id|
  container_id = run_docker_command("inspect --format='{{.Id}}' #{container_id}").strip
  container_name = run_docker_command("inspect --format='{{.Name}}' #{container_id}").strip
  container_creation_date = run_docker_command("inspect --format='{{.Created}}' #{container_id}").strip
  table_data << ["?", container_id[0,10], container_name, container_creation_date]
end

pack_response "docker_containers",  {:totalItems => containers.length, :perPage => '10', :data => table_data}


