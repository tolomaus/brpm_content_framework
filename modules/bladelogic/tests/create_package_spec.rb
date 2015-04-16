require "#{File.dirname(__FILE__)}/spec_helper"

describe 'create package' do
  describe '' do
    it 'should create a package in BladeLogic' do  # need to add logic to delete the bl package in Bladelogic
      params = get_default_params
      params = params.merge(get_integration_settings_for_bladelogic)

      params["application"] = 'E-Finance'
      params["component"] = 'EF - Java calculation engine'
      params["component_version"] = '1.0.0'

      BrpmAuto.execute_script_from_module("bladelogic", "create_package", params)

      version_tag = BrpmRest.get_version_tag("E-Finance","EF - Java calculation engine", "development", "1.0.0")
      expect(version_tag).not_to be_nil
    end
  end

  before(:all) do
    cleanup_package "/Applications/E-Finance/EF - Java calculation engine", "1.0.0"
  end
end

