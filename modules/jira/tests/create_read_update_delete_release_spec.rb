require "#{File.dirname(__FILE__)}/spec_helper"

describe 'create/read/update/delete release' do
  describe '' do
    it 'should create/read/update/delete release in jira' do
      params = get_default_params
      params = params.merge(get_integration_details_for_jira)

      params["application_name"] = 'E-Finance'
      params["application_version"] = '1.0.0'
      params["release_request_template_name"] = 'Release E-Finance'

      execute_script_from_module("jira", "create_release", params)

      brpm_client = get_brpm_client

      request = brpm_client.get_request_by_id(params["result"]["request_id"])

      expect(request["aasm_state"]).to eq("started")
      expect(request).not_to have_key("plan_member")
    end
  end

  describe 'in plan' do
    it 'should create a plan from template and a request from template in that plan' do
      params = get_default_params
      params["application_name"] = 'E-Finance'
      params["application_version"] = '1.0.1'
      params["release_request_template_name"] = 'Release E-Finance'
      params["release_plan_template_name"] = 'E-Finance Release Plan'

      execute_script_from_module("brpm", "create_release_request", params)

      brpm_client = get_brpm_client

      request = brpm_client.get_request_by_id(params["result"]["request_id"])

      expect(request["aasm_state"]).to eq("started")
      expect(request).to have_key("plan_member")
      expect(request["plan_member"]["plan"]["id"]).not_to be_nil
    end
  end

  before(:each) do
    cleanup_requests_and_plans_for_app("E-Finance")
  end
end

