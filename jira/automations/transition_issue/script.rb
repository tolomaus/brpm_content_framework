require "jira/lib/jira_rest_api"

def execute_script(params)
  Logger.log "Logging in to JIRA instance #{params["SS_integration_dns"]} with username #{params["SS_integration_username"]}..."
  jira_client = Jira::Client.new(params["SS_integration_username"],
                                 decrypt_string_with_prefix(params["SS_integration_password_enc"]),
                                 params["SS_integration_dns"])

  Logger.log "Setting the status of issue #{params["issue_id"]} to #{params["target_issue_status"]}"
  jira_client.set_issue_to_status(params["issue_id"], params["target_issue_status"])
end