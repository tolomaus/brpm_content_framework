require "brpm/lib/brpm_rest_api"
require "jira/lib/jira_rest_api"
require "#{File.dirname(__FILE__)}/jira_mappings"

def process_event(event)
  set_brpm_rest_api_url("http://localhost:#{ENV["EVENT_HANDLER_BRPM_PORT"]}/brpm")
  set_brpm_rest_api_token(ENV["EVENT_HANDLER_BRPM_TOKEN"])

  if event.has_key?("request")
    Logger.log  "The event is for a request #{event["event"][0]}..."
    process_request_event(event)
  elsif event.has_key?("run")
    Logger.log  "The event is for a run #{event["event"][0]}..."
    process_run_event(event)
  end
end

def process_request_event(event)
  if  event["event"][0] == "update"
    request_old_state = event["request"].find { |item| item["type"] == "old" }
    request_new_state = event["request"].find { |item| item["type"] == "new" }

    if request_old_state["aasm-state"][0] != request_new_state["aasm-state"][0] or request_new_state["aasm-state"][0] == "complete" #TODO bug when a request is moved to complete the old state is also reported as complete
      Logger.log "Request '#{request_new_state["name"][0]}' moved from state '#{request_old_state["aasm-state"][0]}' to state '#{request_new_state["aasm-state"][0]}'"

      process_app_release_event(request_new_state)

      update_tickets_in_jira_by_request(request_new_state)
    end
  end
end

def process_run_event(event)
  if  event["event"][0] == "update"
    run_old_state = event["run"].find { |item| item["type"] == "old" }
    run_new_state = event["run"].find { |item| item["type"] == "new" }

    if run_old_state["aasm-state"][0] != run_new_state["aasm-state"][0]
      Logger.log "Run '#{run_new_state["name"][0]}' moved from state '#{run_old_state["aasm-state"][0]}' to state '#{run_new_state["aasm-state"][0]}'"

      update_tickets_in_jira_by_run(run_new_state)
    end
  end
end

#################################

def process_app_release_event(request)
  release_request_stage_name = "Release"
  release_request_environment_name = "development"
  release_request_template_prefix = "Release"
  deployment_request_stage_name = "Entrance"

  if request["aasm-state"][0] == "planned"
    request_with_details = get_request_by_id(request["id"][0]["content"])
    if request_with_details.has_key?("plan_member")
      plan_id = request_with_details["plan_member"]["plan"]["id"]
      plan_name = request_with_details["plan_member"]["plan"]["name"]
      stage_name = request_with_details["plan_member"]["stage"]["name"]
      app_name = request_with_details["apps"][0]["name"]
      release_request_name = request_with_details["name"].sub("Deploy", "Release")

      if stage_name == deployment_request_stage_name
        Logger.log "Creating an app release request for plan '#{plan_name}' and app '#{app_name}' ..."
        create_request_for_plan_from_template(plan_id, release_request_stage_name, "#{release_request_template_prefix} #{app_name}", release_request_name, release_request_environment_name, true)
      end
    end
  end
end

def update_tickets_in_jira_by_request(request)
  if request["aasm-state"][0] == "complete"
    params = {}
    params["request_id"] = request["id"][0]["content"]

    Logger.log "Getting the target status for the issues in JIRA..."
    params["target_issue_status"] = map_stage_to_issue_status(stage_name)

    execute_script_from_module("jira", "transition_issues_for_request", params)
  end
end

def update_tickets_in_jira_by_run(run)
  if run["aasm-state"][0] == "completed"
    params = {}
    params["run_id"] = run["id"][0]["content"]

    Logger.log  "Getting the stage of this run..."
    stage = get_plan_stage_by_id(run["plan_stage_id"][0]["content"])

    Logger.log "Getting the target status for the issues in JIRA..."
    params["target_issue_status"] = map_stage_to_issue_status(stage["name"])

    execute_script_from_module("jira", "transition_issues_for_run", params)
  end
end





