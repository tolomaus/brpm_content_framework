require "#{File.dirname(__FILE__)}/spec_helper"

describe 'create release request' do
  before(:each) do
    @brpm_rest_client = BrpmRestClient.new('http://brpm-content.pulsar-it.be:8088/brpm', ENV["BRPM_API_TOKEN"])

    cleanup_requests_and_plans_for_app("E-Finance")
  end

  describe '' do
    it 'should create a request from template' do
      params = get_default_params
      params["application_name"] = 'E-Finance'
      params["application_version"] = '1.0.0'
      params["release_request_template_name"] = 'Release E-Finance'

      output_params = BrpmAuto.execute_script_from_module("brpm", "create_release_request", params)

      request = @brpm_rest_client.get_request_by_id(output_params["request_id"])

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

      output_params = BrpmAuto.execute_script_from_module("brpm", "create_release_request", params)

      request = @brpm_rest_client.get_request_by_id(output_params["request_id"])

      expect(request["aasm_state"]).to eq("started")
      expect(request).to have_key("plan_member")
      expect(request["plan_member"]["plan"]["id"]).not_to be_nil
    end
  end
end

