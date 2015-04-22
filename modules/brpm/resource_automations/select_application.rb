def execute_resource_automation_script(params, parent_id, offset, max_records)
  BrpmAuto.log "Finding all applications..."
  apps = BrpmRest.get_apps()

  apps = apps.sort_by { |app| app["name"] }

  BrpmAuto.log "Adding the #{apps.count} found applications to the list..."
  results = []
  apps.each do |app|
    results << { app["name"] => app["id"].to_i }
  end

  results
end