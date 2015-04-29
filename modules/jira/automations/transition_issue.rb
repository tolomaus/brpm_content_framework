
def execute_script(params)
  BrpmAuto.log "Setting the status of issue #{params["issue_id"]} to #{params["target_issue_status"]}"
  JiraRestClient.set_issue_to_status(params["issue_id"], params["target_issue_status"])
end