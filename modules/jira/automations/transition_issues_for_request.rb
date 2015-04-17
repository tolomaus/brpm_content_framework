def execute_script(params)
  Logger.log  "Getting the tickets that are linked to the request..."
  tickets = BrpmRest.get_tickets_by_request_id(params["request_id"])

  if tickets.count == 0
    Logger.log "This request has no tickets, nothing further to do."
    return
  end

  unless params["target_issue_status"]
    Logger.log  "Getting the stage of this request..."
    request_with_details = BrpmRest.get_request_by_id(params["request_id"])

    if request_with_details.has_key?("plan_member")
      stage_name = request_with_details["plan_member"]["stage"]["name"]

      params["target_issue_status"] = "Deployed to #{stage_name}"
    else
      Logger.log "The request is not part of a plan so not processing the tickets."
      return
    end
  end

  tickets.each do |ticket|
    Logger.log "Setting the status of issue #{ticket["foreign_id"]} to #{params["target_issue_status"]}"
    JiraRest.set_issue_to_status(ticket["foreign_id"], params["target_issue_status"])
  end
end