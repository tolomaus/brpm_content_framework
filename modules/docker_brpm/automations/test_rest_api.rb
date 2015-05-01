params = BrpmAuto.params
request_params = BrpmAuto.request_params

ENV["DOCKER_HOST"] = get_docker_host_name
ENV["BRPM_PORT"] = params["port"]
ENV["BRPM_API_TOKEN"] = params["api_token"]

BrpmAuto.log "Running the tests ..."
BrpmAuto.log BrpmAuto.exec_command("#{params["local_debug"] == 'true' ? "" : "jruby -S"} rspec #{File.dirname(__FILE__)}/../spec --format html --out #{params["SS_output_dir"]}/rspec_results.html")

BrpmAuto.log "Storing the test results url ..."
output_dir = params["SS_output_dir"].slice(params["SS_output_dir"].index("automation_results")..-1)

test_results_url = "#{params["SS_base_url"]}/#{output_dir}/rspec_results.html"

request_params["test_results_url"] = test_results_url


