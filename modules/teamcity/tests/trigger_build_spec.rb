require "#{File.dirname(__FILE__)}/spec_helper"

describe 'trigger build' do
  before(:all) do
    setup_brpm_auto
  end

  before(:each) do
    #cleanup_release('TeamCity tests - release 1')
  end

  describe '' do
    it 'should trigger a build in TeamCity' do
      params = get_default_params
      params = params.merge(get_integration_params_for_teamcity)

      params["application"] = 'E-Finance'
      params["application"] = 'EF - java calculation engine'
      BrpmScriptExecutor.execute_automation_script("teamcity", "trigger_build", params)

      #verify the tests: check if the build was triggered succesfully
      #build = @teamcity_rest_client.get_build(...)
      #expect(build).not_to be_nil
    end
  end
end

