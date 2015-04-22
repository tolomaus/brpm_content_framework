require "framework/lib/request_params"
require "framework/lib/rest_api"
require "docker_brpm/lib/docker"

def execute_script(params)
  request_params = get_request_params()

  jenkins_username = params["SS_integration_username"]
  jenkins_password = decrypt_string_with_prefix(params["SS_integration_password_enc"])

  jenkins_host = params["SS_integration_dns"].sub("://", "://#{jenkins_username}:#{jenkins_password}@")
  jenkins_job = "DockerizedBRPM_#{request_params["jenkins_job"]}"

  result = rest_get "#{jenkins_host}/job/#{jenkins_job}/api/json"
  build_number = result["response"]["nextBuildNumber"]

  # TODO: find out why passing the parameters as a json structure in the body doesn't work
  job_params = []
  job_params << { :name => "DOCKER_HOST", :value => get_docker_host_name }
  job_params << { :name => "BRPM_PORT", :value => params["port"] }
  job_params << { :name => "BRPM_API_TOKEN", :value => params["api_token"] }

  # TODO: make the rest client work with the username/password as specified in the options (right now the username/password are taken from the jenkins url)
  options = {}
  options["username"] = jenkins_username
  options["password"] = jenkins_password

  jenkins_test_rest_api_url = "#{jenkins_host}/job/#{jenkins_job}/buildWithParameters?DOCKER_HOST=#{get_docker_host_name}&BRPM_PORT=#{params["port"]}&BRPM_API_TOKEN=#{params["api_token"]}"

  BrpmAuto.log "Triggering jenkins to execute the tests ..."
  rest_post jenkins_test_rest_api_url, { :parameter => job_params }, options

  raise("build_number not received") if build_number.nil?

  jenkins_build_status_url = "#{jenkins_host}/job/#{jenkins_job}/#{build_number}/api/json"

  build_result = nil
  while build_result.nil?
    sleep(15)

    result = rest_get jenkins_build_status_url
    build_result = result["response"]["result"]
  end

  raise("Error monitoring jenkins build #{jenkins_build_status_url}: #{build_result}") unless build_result == "SUCCESS"
end


