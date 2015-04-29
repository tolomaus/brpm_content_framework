require "#{File.dirname(__FILE__)}/spec_helper"

describe 'deploy package' do
  before(:all) do
    setup_brpm_auto
  end

  describe '' do
    it 'should deploy a package in BladeLogic' do
      params = get_default_params
      params = params.merge(get_integration_params_for_bladelogic)

      params["application"] = 'E-Finance'
      params["component"] = 'EF - Java calculation engine'
      params["component_version"] = '2.0.0'
      params["request_environment"] = "development"
      params["server_group"] = "EF - java app servers - development"

      BrpmScriptExecutor.execute_automation_script("bladelogic", "deploy_package", params)
    end
  end
end

