require_relative "spec_helper"

describe 'execute test' do
  before(:all) do
    setup_brpm_auto
  end

  it 'should execute a test' do
    params = get_default_params
    params = params.merge(get_integration_params_for_bladelogic)

    params["application"] = 'E-Finance'
    params["component"] = 'EF - Java calculation engine'
    params["component_version"] = '1.0.0'

    BrpmScriptExecutor.execute_automation_script("my_module", "my_automation_script", params)
  end
end

