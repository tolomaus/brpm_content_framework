brpm_rest_client = BrpmRestClient.new
params = BrpmAuto.params

run_id = params["request_run_id"] || params["run_id"]

BrpmAuto.log  "Getting the tickets that are linked to the requests of this run..."
tickets = brpm_rest_client.get_tickets_by_run_id_and_request_state(run_id, "completed")

if tickets.count == 0
  BrpmAuto.log "This run has no tickets, nothing further to do."
  return
end

unless params["target_issue_status"]
  if params["request_plan_stage"]
    params["target_issue_status"] = "Deployed to #{params["request_plan_stage"]}"
  else
    BrpmAuto.log "The request is not part of a plan so not processing the tickets."
    return
  end
end

tickets.each do |ticket|
  BrpmAuto.log "Setting the status of issue #{ticket["foreign_id"]} to #{params["target_issue_status"]}"
  JiraRestClient.new.set_issue_to_status(ticket["foreign_id"], params["target_issue_status"])
end
