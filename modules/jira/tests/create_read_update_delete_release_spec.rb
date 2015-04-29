require "#{File.dirname(__FILE__)}/spec_helper"

describe 'create/update/delete release' do
  before(:each) do
    @jira_rest_client = JiraRestClient.new

    cleanup_release('JIRA tests - release 1')
    cleanup_release('JIRA tests - release 1 - updated')
  end

  describe '' do
    it 'should create/update/delete release in jira' do
      params = get_default_params
      params = params.merge(get_integration_params_for_jira)

      params["release_name"] = 'JIRA tests - release 1'
      BrpmAuto.execute_script_from_module("jira", "create_release", params)

      option = @jira_rest_client.get_option_for_dropdown_custom_field(params["jira_release_field_id"], 'JIRA tests - release 1')
      expect(option).not_to be_nil

      params["old_release_name"] = 'JIRA tests - release 1'
      params["new_release_name"] = 'JIRA tests - release 1 - updated'
      BrpmAuto.execute_script_from_module("jira", "update_release", params)

      option = @jira_rest_client.get_option_for_dropdown_custom_field(params["jira_release_field_id"], 'JIRA tests - release 1 - updated')
      expect(option).not_to be_nil

      params["release_name"] = 'JIRA tests - release 1 - updated'
      BrpmAuto.execute_script_from_module("jira", "delete_release", params)

      option = @jira_rest_client.get_option_for_dropdown_custom_field(params["jira_release_field_id"], 'JIRA tests - release 1 - updated')
      expect(option).to be_nil
    end
  end
end

