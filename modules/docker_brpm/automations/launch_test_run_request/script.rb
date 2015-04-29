require "framework/lib/request_params"
require "brpm/lib/brpm_rest_client"

def execute_script(params)
  request_params = get_request_params()

  new_request_params = {}
  new_request_params["calling_request"] = params["SS_request_number"]
  new_request_params["jenkins_job"] = params["jenkins_job"]

  BrpmAuto.log "Creating a new request from template 'Execute test run in Jenkins' for test run #{new_request_params["jenkins_job"]} and BRPM v#{request_params["application_version"]} ..."
  new_request = create_request_for_plan_from_template(
      params["request_plan_id"].to_i,
      params["new_request_stage"],
      "Execute test run in Jenkins",
      "Execute test run #{new_request_params["jenkins_job"]} in Jenkins for BRPM v#{request_params["application_version"]}",
      params["new_request_environment"],
      false, #execute_now
      new_request_params
  )

  BrpmAuto.log "Setting the version number of the steps that are linked to component 'Application' to #{request_params["application_version"]} ... "
  set_version_tag_of_steps_for_component(new_request, "Application", request_params["application_version"])

  BrpmAuto.log "Planning the request ... "
  plan_request(new_request["id"])

  BrpmAuto.log "Starting the request ... "
  start_request(new_request["id"])

  BrpmAuto.log "Waiting until the request has finished ..."
  monitor_request(new_request["id"], { :max_time => 20*60, :checking_interval => params["checking_interval"] })
end