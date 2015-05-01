require 'fileutils'

params = BrpmAuto.params
request_params = BrpmAuto.request_params

application_version = request_params["application_version"]

docker_workspace = clone_git_repo("docker_brpm_db_init", params["SS_output_dir"])

BrpmAuto.log "Setting the the base image to bmc_devops/brpm:v#{application_version} in the Dockerfile ..."

dockerfile_location = "#{docker_workspace}/Dockerfile"
dockerfile_content = File.read(dockerfile_location)
dockerfile_content.sub!(/FROM .*/, "FROM bmc_devops/brpm:v#{application_version}")

File.open(dockerfile_location, "w") do |file|
  file << dockerfile_content
end

BrpmAuto.log "Creating the image ..."
run_docker_command("build --rm -t bmc_devops/brpm_db_init:v#{application_version} #{docker_workspace}")
