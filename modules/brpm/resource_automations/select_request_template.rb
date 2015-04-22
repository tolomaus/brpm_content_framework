def execute_resource_automation_script(params, parent_id, offset, max_records)
  BrpmAuto.log "Finding all request templates for application #{params["application"]}..."
  request_templates = BrpmRest.get_request_templates_by_app(params["application"])

  request_templates = request_templates.sort_by { |request_template| request_template["name"] }

  BrpmAuto.log "Adding the #{request_templates.count} found request templates to the list..."
  results = []
  request_templates.each do |request_template|
    results << { request_template["name"] => request_template["id"].to_i }
  end

  results
end