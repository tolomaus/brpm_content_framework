require "jira/lib/jira_rest_api"
require "brpm/lib/brpm_rest_api"

def execute_script(params)
  Logger.log  "Getting the tickets that are linked to the request..."
  tickets = get_tickets_by_request_id(params["request_id"])

  if tickets.count == 0
    Logger.log "This request has no tickets, nothing further to do."
    return
  end

  unless params["target_issue_status"]
    Logger.log  "Getting the stage of this request..."
    request_with_details = get_request_by_id(params["request_id"])

    if request_with_details.has_key?("plan_member")
      stage_name = request_with_details["plan_member"]["stage"]["name"]

      params["target_issue_status"] = "Deployed to #{stage_name}"
    else
      Logger.log "The request is not part of a plan so not processing the tickets."
      return
    end
  end

  jira_client = Jira::Client.new(params["SS_integration_username"],
                                 decrypt_string_with_prefix(params["SS_integration_password_enc"]),
                                 params["SS_integration_dns"])

  Logger.log "Logging in to JIRA instance #{params["SS_integration_dns"]} with username #{params["SS_integration_username"]}..."
  jira_client.login()

  tickets.each do |ticket|
    Logger.log "Setting the status of issue #{ticket["foreign_id"]} to #{params["target_issue_status"]}"
    jira_client.set_issue_to_status(ticket["foreign_id"], params["target_issue_status"])
  end

  jira_client.logout()
end