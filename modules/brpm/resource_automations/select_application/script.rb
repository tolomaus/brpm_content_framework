load "brpm/lib/brpm_rest_api.rb"

def execute_resource_automation_script(params, parent_id, offset, max_records)
  Logger.log "Finding all applications..."
  apps = get_apps()

  apps = apps.sort_by { |app| app["name"] }

  Logger.log "Adding the #{apps.count} found applications to the list..."
  results = []
  apps.each do |app|
    results << { app["name"] => app["id"].to_i }
  end

  results
end