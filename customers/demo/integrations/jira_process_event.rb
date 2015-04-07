require "brpm/lib/brpm_rest_api"
require "#{File.dirname(__FILE__)}/jira_mappings"

def process_event(event)
  Logger.log "Processing event #{event["id"]} ..."

  brpm_client = Brpm::Client.new("http://#{ENV["WEBHOOK_RECEIVER_BRPM_HOST"]}:#{ENV["WEBHOOK_RECEIVER_BRPM_PORT"]}/brpm", ENV["WEBHOOK_RECEIVER_BRPM_TOKEN"])

  issue = event["issue"]

  Logger.log "Validating the issue..."
  unless is_issue_valid(issue)
    raise "Validation error, see the log file for more information."
  end

  # Prepare the ticket placeholder we will use to create or update the ticket
  ticket = {}
  ticket["project_server_id"] = ENV["WEBHOOK_RECEIVER_INTEGRATION_ID"]

  Logger.log "Associating the ticket with a plan..."
  if issue["fields"]["customfield_#{ENV["WEBHOOK_RECEIVER_JIRA_RELEASE_FIELD_ID"]}"]
    plan = brpm_client.get_plan_by_name(issue["fields"]["customfield_#{ENV["WEBHOOK_RECEIVER_JIRA_RELEASE_FIELD_ID"]}"]["value"])
    ticket["plan_ids"] = [ plan["id"] ] unless plan.nil?
  end

  Logger.log "Mapping the issue to the ticket..."
  map_issue_to_ticket(issue, ticket)

  Logger.log "Creating or updating the ticket..."
  brpm_client.create_or_update_ticket(ticket)

  Logger.log "Finished processing the event."
end
