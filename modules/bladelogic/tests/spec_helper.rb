require 'fileutils'
FileUtils.mkdir_p "/tmp/brpm_content/step_1"

require "#{File.dirname(__FILE__)}/../../framework/brpm_automation"
BrpmAuto.setup_logger("/tmp/brpm_content/tests.log", true) # TODO clean up
RequestParams.setup("/tmp/brpm_content/") # TODO clean up

BrpmAuto.require_module "brpm"
BrpmRest.setup('http://brpm-content.pulsar-it.be:8088/brpm', ENV["BRPM_API_TOKEN"])

BrpmAuto.require_module "bladelogic"
BsaSoap.setup("https://bladelogic.pulsar-it.be:9843", "BLAdmin", ENV["BLADELOGIC_PASSWORD"], "BLAdmins")

def get_default_params
  params = {}
  params['debug'] = 'true'
  params['SS_base_url'] = 'http://brpm-content.pulsar-it.be:8088/brpm'
  params['SS_api_token'] = ENV["BRPM_API_TOKEN"]

  dir = "/tmp/brpm_content/step_1"
  params['SS_output_dir'] = dir # TODO clean up

  params
end

def get_integration_settings_for_bladelogic
  params = {}
  params["SS_integration_dns"] = "https://bladelogic.pulsar-it.be:9843"
  params["SS_integration_username"] = "BLAdmin"
  params["SS_integration_password"] = ENV["BLADELOGIC_PASSWORD"]
  params["SS_integration_details"] = {}
  params["SS_integration_details"]["role"] = "BLAdmins"

  params
end

def cleanup_request_data_file
  file = RequestParams.file_location
  File.delete(file) if File.exist?(file) # TODO clean up
end

def cleanup_requests_and_plans_for_app(app_name)
  app = BrpmRest.get_app_by_name(app_name)

  requests = BrpmRest.get_requests_by({ "app_id" => app["id"]})

  requests.each do |request|
    BrpmRest.delete_request(request["id"]) unless request.has_key?("request_template")
  end

  plan_template = BrpmRest.get_plan_template_by_name("#{app_name} Release Plan")

  plans = BrpmRest.get_plans_by({ "plan_template_id" => plan_template["id"]})
  plans.each do |plan|
    BrpmRest.cancel_plan(plan["id"])
    BrpmRest.delete_plan(plan["id"])
  end
end

def cleanup_version_tags_for_app(app_name)
  app = BrpmRest.get_app_by_name(app_name)

  version_tags = BrpmRest.get_version_tags_by({ "app_id" => app["id"]})

  version_tags.each do |version_tag|
    BrpmRest.delete_version_tag(version_tag["id"])
  end
end

def cleanup_package path, name
  BrpmAuto.log("Logging on to Bladelogic...")
  session_id = BsaSoap.login

  BrpmAuto.log("Deleting blpackage #{path}/#{name}...")
  begin
    BlPackage.delete_blpackage_by_group_and_name(session_id, { :parent_group => path, :package_name => name })
  rescue Exception => ex
    if ex.message =~ /Cannot find depot object by name/
      BrpmAuto.log "assuming that the package didn't exist so all is fine."
    else
      raise ex
    end
  end
end

def pack_response key, value
  BrpmAuto.log "pack_response: #{key}: #{value}"
end