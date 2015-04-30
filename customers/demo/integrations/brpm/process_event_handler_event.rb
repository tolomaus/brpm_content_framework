BrpmAuto.require_module "brpm"
require "#{File.dirname(__FILE__)}/../../jira_mappings"

def process_event(event)
  @brpm_rest_client = BrpmRestClient.new("http://#{ENV["EVENT_HANDLER_BRPM_HOST"]}:#{ENV["EVENT_HANDLER_BRPM_PORT"]}/brpm", ENV["EVENT_HANDLER_BRPM_TOKEN"])

  if event.has_key?("request")
    BrpmAuto.log "The event is for a request #{event["event"][0]}..."
    process_request_event(event)
  elsif event.has_key?("run")
    BrpmAuto.log "The event is for a run #{event["event"][0]}..."
    process_run_event(event)
  elsif event.has_key?("plan")
    BrpmAuto.log "The event is for a plan #{event["event"][0]}..."
    process_plan_event(event)
  end
end

def process_request_event(event)
  if event["event"][0] == "create"
    request = event["request"].find { |item| item["type"] == "new" }

    BrpmAuto.log "Request '#{request["name"][0]}' created"
  elsif event["event"][0] == "update"
    request_old_state = event["request"].find { |item| item["type"] == "old" }
    request_new_state = event["request"].find { |item| item["type"] == "new" }

    if request_old_state["aasm-state"][0] != request_new_state["aasm-state"][0] or request_new_state["aasm-state"][0] == "complete" #TODO bug when a request is moved to complete the old state is also reported as complete
      BrpmAuto.log "Request '#{request_new_state["name"][0]}' moved from state '#{request_old_state["aasm-state"][0]}' to state '#{request_new_state["aasm-state"][0]}'"

      if request["aasm-state"][0] == "completed"
        process_app_release_event(request_new_state)
        update_tickets_in_jira_by_request(request_new_state)
      end
    end
  end
end

def process_run_event(event)
  if event["event"][0] == "create"
    run = event["run"].find { |item| item["type"] == "new" }

    BrpmAuto.log "Run '#{run["name"][0]}' created"
  elsif event["event"][0] == "update"
    run_old_state = event["run"].find { |item| item["type"] == "old" }
    run_new_state = event["run"].find { |item| item["type"] == "new" }

    if run_old_state["aasm-state"][0] != run_new_state["aasm-state"][0]
      BrpmAuto.log "Run '#{run_new_state["name"][0]}' moved from state '#{run_old_state["aasm-state"][0]}' to state '#{run_new_state["aasm-state"][0]}'"

      if request["aasm-state"][0] == "completed"
        update_tickets_in_jira_by_run(run_new_state)
      end
    end
  end
end

def process_plan_event(event)
  if event["event"][0] == "create"
    plan = event["plan"].find { |item| item["type"] == "new" }

    BrpmAuto.log "Plan '#{plan["name"][0]}' created"

    create_release_in_jira(plan)

  elsif event["event"][0] == "update"
    plan_old_state = event["plan"].find { |item| item["type"] == "old" }
    plan_new_state = event["plan"].find { |item| item["type"] == "new" }

    if plan_old_state["aasm-state"][0] != plan_new_state["aasm-state"][0]
      BrpmAuto.log "Plan '#{plan_new_state["name"][0]}' moved from state '#{plan_old_state["aasm-state"][0]}' to state '#{plan_new_state["aasm-state"][0]}'"
    end

    if plan_new_state["name"][0].start_with?(plan_old_state["name"][0] + " [deleted ")
      BrpmAuto.log "Plan '#{plan_old_state["name"][0]}' deleted"

      delete_release_in_jira(plan_old_state)

    elsif plan_old_state["name"][0] != plan_new_state["name"][0]
      BrpmAuto.log "Plan '#{plan_new_state["name"][0]}' moved from state '#{plan_old_state["aasm-state"][0]}' to state '#{plan_new_state["aasm-state"][0]}'"

      update_release_in_jira(plan_old_state, plan_new_state)

    end
  end
end

#################################
# BRPM

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
        BrpmAuto.log "Creating an app release request for plan '#{plan_name}' and app '#{app_name}' ..."
        @brpm_rest_client.create_request_for_plan_from_template(plan_id, release_request_stage_name, "#{release_request_template_prefix} #{app_name}", release_request_name, release_request_environment_name, true)
      end
    end
  end
end
#################################

#################################
# JIRA

def get_jira_integration_settings
  params = {}
  params["SS_integration_dns"] = ENV["EVENT_HANDLER_JIRA_URL"]
  params["SS_integration_username"] = ENV["EVENT_HANDLER_JIRA_USERNAME"]
  params["SS_integration_password"] = ENV["EVENT_HANDLER_JIRA_PASSWORD"]

  params
end

def update_tickets_in_jira_by_request(request)
  params = get_jira_integration_settings
  params["request_id"] = request["id"][0]["content"]

  BrpmAuto.log "Getting the stage of this request..."
  stage = @brpm_rest_client.get_plan_stage_by_id(run["plan_stage_id"][0]["content"])

  BrpmAuto.log "Getting the target status for the issues in JIRA..."
  params["target_issue_status"] = map_stage_to_issue_status(stage_name)

  BrpmScriptExecutor.execute_automation_script("jira", "transition_issues_for_request", params)
end

def update_tickets_in_jira_by_run(run)
  params = get_jira_integration_settings
  params["run_id"] = run["id"][0]["content"]

  BrpmAuto.log "Getting the stage of this run..."
  stage = @brpm_rest_client.get_plan_stage_by_id(run["plan_stage_id"][0]["content"])

  BrpmAuto.log "Getting the target status for the issues in JIRA..."
  params["target_issue_status"] = map_stage_to_issue_status(stage["name"])

  BrpmScriptExecutor.execute_automation_script("jira", "transition_issues_for_run", params)
end

def create_release_in_jira(plan)
  params = get_jira_integration_settings
  params["jira_release_field_id"] = ENV["EVENT_HANDLER_JIRA_RELEASE_FIELD_ID"]
  params["release_name"] = plan["name"][0]

  BrpmScriptExecutor.execute_automation_script("jira", "create_release", params)
end

def update_release_in_jira(old_plan, new_plan)
  params = get_jira_integration_settings
  params["jira_release_field_id"] = ENV["EVENT_HANDLER_JIRA_RELEASE_FIELD_ID"]
  params["old_release_name"] = old_plan["name"][0]
  params["new_release_name"] = new_plan["name"][0]

  BrpmScriptExecutor.execute_automation_script("jira", "update_release", params)
end

def delete_release_in_jira(plan)
  params = get_jira_integration_settings
  params["jira_release_field_id"] = ENV["EVENT_HANDLER_JIRA_RELEASE_FIELD_ID"]
  params["release_name"] = plan["name"][0]

  BrpmScriptExecutor.execute_automation_script("jira", "delete_release", params)
end
#################################