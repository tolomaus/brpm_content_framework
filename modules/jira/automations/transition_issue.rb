
def execute_script(params)
  Logger.log "Setting the status of issue #{params["issue_id"]} to #{params["target_issue_status"]}"
  JiraRest.set_issue_to_status(params["issue_id"], params["target_issue_status"])
end