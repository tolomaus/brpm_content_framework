# TODO workaround bug fix where the request params are not transferred to the updated application's directory
require 'fileutils'

def execute_script(params)
  BrpmAuto.log "Retrieving the application..."
  application = BrpmRest.get_app_by_name(params["application_name"])
  application_version = params["application_version"]

  release_request_template_name = params["release_request_template_name"] || "Release application"
  release_plan_template_name = params["release_plan_template_name"]

  request_name = "Release #{application["name"]} #{application_version}"

  if release_plan_template_name
    BrpmAuto.log "Creating a new plan from template '#{release_plan_template_name}' for #{application["name"]} v#{application_version} ..."
    plan = BrpmRest.create_plan(release_plan_template_name, "Release #{params["application_name"]} v#{application_version}", Time.now)

    BrpmAuto.log "Planning the plan ..."
    BrpmRest.plan_plan(plan["id"])

    BrpmAuto.log "Starting the plan ..."
    BrpmRest.start_plan(plan["id"])

    BrpmAuto.log "Creating a new request '#{request_name}' from template '#{release_request_template_name}' for application '#{application["name"]}' and plan #{plan["name"]}..."
    target_request = BrpmRest.create_request_for_plan_from_template(
        plan["id"],
        "Release",
        release_request_template_name,
        request_name,
        "release",
        false, # execute_now
        { :application_version => application_version, :auto_created => true }
    )
  else
    BrpmAuto.log "Creating a new request '#{request_name}' from template '#{release_request_template_name}' for application '#{application["name"]}'..."
    target_request = BrpmRest.create_request(
        release_request_template_name,
        request_name,
        "release",
        false, # execute_now
        { :application_version => application_version, :auto_created => true }
    )
  end

  unless target_request["apps"].first["id"] == application["id"]
    BrpmAuto.log "The application from the template is different than the application we want to use so updating the request with the correct application..."
    request = {}
    request["id"] = target_request["id"]
    request["app_ids"] = [application["id"]]
    target_request = BrpmRest.update_request_from_hash(request)

    # TODO workaround bug fix where the request params are not transferred to the updated application's directory
    Dir.mkdir "#{params["SS_automation_results_dir"]}/request/#{application["name"]}/#{1000 + target_request["id"].to_i}"
    json = FileUtils.mv("#{params["SS_automation_results_dir"]}/request/#{target_request["apps"].first["name"]}/#{1000 + target_request["id"].to_i}/request_data.json", "#{params["SS_automation_results_dir"]}/request/#{application["name"]}/#{1000 + target_request["id"].to_i}/request_data.json")

    BrpmAuto.log "Setting the owner of the manual steps to the groups that belong to application '#{application["name"]}'..."
    target_request["steps"].select{ |step| step["manual"] }.each do |step|
      BrpmAuto.log "Retrieving the details of step #{step["id"]} '#{step["name"]}'..."
      step_details = BrpmRest.get_step_by_id(step["id"])

      next if step_details["procedure"]

      group_name = "#{step_details["owner"]["name"]} - #{application["name"]}"

      BrpmAuto.log "Retrieving group #{group_name}..."
      group = BrpmRest.get_group_by_name(group_name)
      raise "Group '#{group_name}' doesn't exist" if group.nil?

      step_to_update = {}
      step_to_update["id"] = step["id"]
      step_to_update["owner_id"] = group["id"]
      step_to_update["owner_type"] = "Group"
      BrpmRest.update_step_from_hash step_to_update
    end
  end

  BrpmAuto.log "Planning the request ... "
  BrpmRest.plan_request(target_request["id"])

  BrpmAuto.log "Starting the request ... "
  BrpmRest.start_request(target_request["id"])

  params["result"] = {}
  params["result"]["request_id"] = target_request["id"]
end

