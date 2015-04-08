load "brpm/lib/brpm_rest_api.rb"

def execute_resource_automation_script(params, parent_id, offset, max_records)
  brpm_client = Brpm::Client.new(params["SS_base_url"], params["SS_api_token"])

  Logger.log "Finding all environments for application #{params["application"]}..."
  environments = brpm_client.get_environments_of_application(params["application"])

  Logger.log "Adding the #{environments.count} found environments to the list..."
  results = []
  environments.each do |environment|
    results << { environment["name"] => environment["id"].to_i }
  end

  results
end