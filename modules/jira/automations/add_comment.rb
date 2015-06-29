params = BrpmAuto.params

BrpmAuto.log "Adding a comment for issue '#{params["issue_id"]}'..."
JiraRestClient.new.add_comment(params["issue_id"], params["comment"])
