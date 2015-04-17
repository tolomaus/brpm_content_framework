def execute_script(params)
  run_id = params["request_run_id"] || params["run_id"]

  Logger.log  "Getting the tickets that are linked to the requests of this run..."
  tickets = BrpmRest.get_tickets_by_run_id_and_request_state(run_id, "completed")

  if tickets.count == 0
    Logger.log "This run has no tickets, nothing further to do."
    return
  end

  unless params["target_issue_status"]
    if params["request_plan_stage"]
      params["target_issue_status"] = "Deployed to #{params["request_plan_stage"]}"
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