require 'fileutils'
require "#{File.dirname(__FILE__)}/../../framework/brpm_script_executor"

def setup_brpm_auto
  FileUtils.mkdir_p "/tmp/brpm_content"

  BrpmAuto.setup( { "output_dir" => "/tmp/brpm_content" }.merge!(get_integration_params_for_bladelogic) )

  BrpmAuto.require_module "brpm"
  BrpmAuto.require_module "bladelogic"

  @brpm_rest_client = BrpmRestClient.new('http://brpm-content.pulsar-it.be:8088/brpm', ENV["BRPM_API_TOKEN"])
  @bsa_soap_client = BsaSoapClient.new
end

def get_default_params
  params = {}
  params['debug'] = 'true'

  params['brpm_url'] = 'http://brpm-content.pulsar-it.be:8088/brpm'
  params['brpm_api_token'] = ENV["BRPM_API_TOKEN"]

  params['output_dir'] = "/tmp/brpm_content"

  params
end

def get_integration_params_for_bladelogic
  params = {}
  params["SS_integration_dns"] = "https://bladelogic.pulsar-it.be:9843"
  params["SS_integration_username"] = "BLAdmin"
  params["SS_integration_password"] = ENV["BLADELOGIC_PASSWORD"]
  params["SS_integration_details"] = {}
  params["SS_integration_details"]["role"] = "BLAdmins"

  params
end

def cleanup_request_data_file
  request_params_file = "/tmp/brpm_content/request_data.json"
  File.delete(request_params_file) if File.exist?(request_params_file)
end

def cleanup_requests_and_plans_for_app(app_name)
  app = @brpm_rest_client.get_app_by_name(app_name)

  requests = @brpm_rest_client.get_requests_by({ "app_id" => app["id"]})

  requests.each do |request|
    @brpm_rest_client.delete_request(request["id"]) unless request.has_key?("request_template")
  end

  plan_template = @brpm_rest_client.get_plan_template_by_name("#{app_name} Release Plan")

  plans = @brpm_rest_client.get_plans_by({ "plan_template_id" => plan_template["id"]})
  plans.each do |plan|
    @brpm_rest_client.cancel_plan(plan["id"])
    @brpm_rest_client.delete_plan(plan["id"])
  end
end

def cleanup_version_tags_for_app(app_name)
  app = @brpm_rest_client.get_app_by_name(app_name)

  version_tags = @brpm_rest_client.get_version_tags_by({ "app_id" => app["id"]})

  version_tags.each do |version_tag|
    @brpm_rest_client.delete_version_tag(version_tag["id"])
  end
end

def cleanup_package path, name
  BrpmAuto.log("Deleting blpackage #{path}/#{name}...")
  begin
    @bsa_soap_client.blpackage.delete_blpackage_by_group_and_name({ :parent_group => path, :package_name => name })
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

setup_brpm_auto
