require "docker_brpm/lib/docker"

def execute_script(params)
  ENV["DOCKER_HOST"] = get_docker_host_name
  ENV["BRPM_PORT"] = params["port"]
  ENV["BRPM_API_TOKEN"] = params["api_token"]

  Logger.log "Running the tests ..."
  Logger.log exec_command("#{params["local_debug"] == 'true' ? "" : "jruby -S"} rspec #{File.dirname(__FILE__)}/../spec --format html --out #{params["SS_output_dir"]}/rspec_results.html")

  Logger.log "Storing the test results url ..."
  output_dir = params["SS_output_dir"].slice(params["SS_output_dir"].index("automation_results")..-1)

  test_results_url = "#{params["SS_base_url"]}/#{output_dir}/rspec_results.html"

  add_request_param("test_results_url", test_results_url)
end


