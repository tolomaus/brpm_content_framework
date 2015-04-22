def execute_script(params)
  BrpmAuto.log "Deleting option for plan '#{params["release_name"]}' in the JIRA dropdown custom field with id #{params["jira_release_field_id"]}..."
  JiraRest.delete_option_for_dropdown_custom_field(params["jira_release_field_id"], params["release_name"])
end