params = BrpmAuto.params

BrpmAuto.log "Updating option for plan from '#{params["old_release_name"]}' to '#{params["new_release_name"]}' in the JIRA dropdown custom field with id #{params["jira_release_field_id"]}..."
JiraRestClient.new.update_option_for_dropdown_custom_field(params["jira_release_field_id"], params["old_release_name"], params["new_release_name"])
