require "#{File.dirname(__FILE__)}/spec_helper"

describe 'create release request' do
  before(:all) do
    setup_brpm_auto
  end

  before(:each) do
    cleanup_requests_and_plans_for_app("E-Finance")
    cleanup_request_params
  end

  describe '' do
    it 'should create a request from template' do
      request_params = {}
      request_params["application_name"] = 'E-Finance'
      request_params["application_version"] = '1.0.0'
      request_params["release_request_template_name"] = 'Release E-Finance'
      set_request_params(request_params)

      params = get_default_params

      BrpmScriptExecutor.execute_automation_script("brpm", "create_release_request", params)

      request = @brpm_rest_client.get_request_by_id(BrpmAuto.params["result"]["request_id"])

      expect(request["aasm_state"]).to eq("started")
      expect(request).not_to have_key("plan_member")
    end
  end

  describe 'in new plan' do
    it 'should create a plan from template and a request from template in that plan' do
      request_params = {}
      request_params["application_name"] = 'E-Finance'
      request_params["application_version"] = '1.0.1'
      request_params["release_request_template_name"] = 'Release E-Finance'
      request_params["release_plan_template_name"] = 'E-Finance Release Plan'
      set_request_params(request_params)

      params = get_default_params

      BrpmScriptExecutor.execute_automation_script("brpm", "create_release_request", params)

      request = @brpm_rest_client.get_request_by_id(BrpmAuto.params["result"]["request_id"])

      expect(request["aasm_state"]).to eq("started")
      expect(request).to have_key("plan_member")
      expect(request["plan_member"]["plan"]["id"]).not_to be_nil
    end
  end

  describe 'in existing plan' do
    it 'should create a request from template in the plan' do
      plan = @brpm_rest_client.create_plan("E-Finance Release Plan", "E-Finance Release Plan v1.0.2")

      request_params = {}
      request_params["application_name"] = 'E-Finance'
      request_params["application_version"] = '1.0.2'
      request_params["release_request_template_name"] = 'Release E-Finance'
      request_params["release_plan_name"] = 'E-Finance Release Plan v1.0.2'
      set_request_params(request_params)

      params = get_default_params

      BrpmScriptExecutor.execute_automation_script("brpm", "create_release_request", params)

      request = @brpm_rest_client.get_request_by_id(BrpmAuto.params["result"]["request_id"])

      expect(request["aasm_state"]).to eq("started")
      expect(request).to have_key("plan_member")
      expect(request["plan_member"]["plan"]["id"]).to eq(plan["id"])
    end
  end
end

