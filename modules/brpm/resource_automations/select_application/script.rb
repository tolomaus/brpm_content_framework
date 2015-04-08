load "brpm/lib/brpm_rest_api.rb"

def execute_resource_automation_script(params, parent_id, offset, max_records)
  brpm_client = Brpm::Client.new(params["SS_base_url"], params["SS_api_token"])

  Logger.log "Finding all applications..."
  apps = brpm_client.get_apps()

  apps = apps.sort_by { |app| app["name"] }

  Logger.log "Adding the #{apps.count} found applications to the list..."
  results = []
  apps.each do |app|
    results << { app["name"] => app["id"].to_i }
  end

  results
end