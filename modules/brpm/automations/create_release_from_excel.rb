require 'simple_xlsx_reader'

def execute_script(params)
  doc = SimpleXlsxReader.open(params["step_attachment_0"])
  Logger.log doc.sheets.first.rows.inspect

  plan = nil
  env_name = nil
  stage_name = nil
  sub_stage_name = nil
  app_name = nil
  request = nil

  doc.sheets.first.rows.each do |row|
    if !row[0].nil?
      Logger.log "Creating a new plan from template 'My Release Plan' for release #{row[0]} ..."
      plan = BrpmRest.create_plan("My Release Plan", row[0], Time.now)
    elsif !row[1].nil?
      env_name = row[1].downcase
      stage_name = row[1]
    elsif !row[2].nil?
      sub_stage_name = row[2]
    elsif !row[3].nil?
      app_name = row[3]
    elsif !row[4].nil?
      Logger.log "Creating a new request '#{row[4]}' for plan '#{plan["name"]}', stage '#{stage_name} - #{sub_stage_name}' and app '#{app_name}' ..."
      request = BrpmRest.create_request_for_plan(plan["id"], "#{stage_name} - #{sub_stage_name}", row[4], 1, app_name, env_name, false)
    elsif !row[5].nil?
      Logger.log "Creating a new step '#{row[5]}' for request '#{request["name"]}' ..."
      BrpmRest.create_step(request["id"], row[5], "User", 1)
    end
  end
end