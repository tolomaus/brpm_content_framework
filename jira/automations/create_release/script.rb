require "jira/lib/jira_rest_api"

def execute_script(params)
  jira_client = Jira::Client.new(params["SS_integration_username"],
                                 params["SS_integration_password"] || decrypt_string_with_prefix(params["SS_integration_password_enc"]),
                                 params["SS_integration_dns"])

  Logger.log "Logging in to JIRA instance #{params["SS_integration_dns"]} with username #{params["SS_integration_username"]}..."
  jira_client.login()
  Logger.log "Creating a new option for release #{params["new_release_name"]} in the JIRA dropdown custom field with id #{params["jira_release_field_id"]}"
  jira_client.create_option_for_dropdown_custom_field(params["jira_release_field_id"], params["new_release_name"])
  jira_client.logout()
end