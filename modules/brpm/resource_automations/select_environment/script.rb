load "brpm/lib/brpm_rest_api.rb"

def execute_resource_automation_script(params, parent_id, offset, max_records)
  Logger.log "Finding all environments for application #{params["application"]}..."
  environments = get_environments_of_application(params["application"])

  Logger.log "Adding the #{environments.count} found environments to the list..."
  results = []
  environments.each do |environment|
    results << { environment["name"] => environment["id"].to_i }
  end

  results
end