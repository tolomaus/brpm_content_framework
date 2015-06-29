require_relative "spec_helper"

describe 'transition issue' do
  before(:all) do
    setup_brpm_auto
  end

  before(:each) do
  end

  describe '' do
    it 'transition an issue in JIRA' do
      params = get_default_params
      params = params.merge(get_integration_params_for_jira)

      params["issue_id"] = "EF-25"

      params["target_issue_status"] = "Done"
      BrpmScriptExecutor.execute_automation_script("jira", "transition_issue", params)

      params["target_issue_status"] = "To Do"
      BrpmScriptExecutor.execute_automation_script("jira", "transition_issue", params)

      params["target_issue_status"] = "In development"
      BrpmScriptExecutor.execute_automation_script("jira", "transition_issue", params)

      params["target_issue_status"] = "Deployed to development"
      BrpmScriptExecutor.execute_automation_script("jira", "transition_issue", params)
    end
  end
end

