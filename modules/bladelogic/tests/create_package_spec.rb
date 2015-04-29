require "#{File.dirname(__FILE__)}/spec_helper"

describe 'create package' do
  before(:all) do
    @brpm_rest_client = BrpmRestClient.new('http://brpm-content.pulsar-it.be:8088/brpm', ENV["BRPM_API_TOKEN"])
    @bsa_soap_client = BsaSoapClient.new

    cleanup_package "/Applications/E-Finance/EF - Java calculation engine", "1.0.0"
  end

  describe '' do
    it 'should create a package in BladeLogic' do  # need to add logic to delete the bl package in Bladelogic
      params = get_default_params
      params = params.merge(get_integration_params_for_bladelogic)

      params["application"] = 'E-Finance'
      params["component"] = 'EF - Java calculation engine'
      params["component_version"] = '1.0.0'

      BrpmAuto.execute_script_from_module("bladelogic", "create_package", params)

      version_tag = @brpm_rest_client.get_version_tag("E-Finance","EF - Java calculation engine", "development", "1.0.0")
      expect(version_tag).not_to be_nil
    end
  end
end

