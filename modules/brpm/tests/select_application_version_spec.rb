require "#{File.dirname(__FILE__)}/spec_helper"

describe 'select application version' do
  describe '' do
    it 'should store the selected application version in the request_params and create version tags' do
      params = get_default_params
      params["application"] = 'E-Finance'
      params["application_version"] = '1.0.0'

      execute_script_from_module("brpm", "select_application_version", params)

      request_params = get_request_params_manager.get_request_params

      request_params.has_key?("application_version")
      expect(request_params["application_version"]).to eq("1.0.0")

      brpm_client = get_brpm_client

      version_tag = brpm_client.get_version_tag("E-Finance","EF - Java calculation engine", "development", "1.0.0")
      expect(version_tag).not_to be_nil
    end
  end

  describe 'with auto_created request_param set' do
    it 'should NOT store the selected application version in the request_params but still create version tags' do
      request_params_manager = get_request_params_manager

      request_params_manager.add_request_param("auto_created", true)
      request_params_manager.add_request_param("application_version", "2.0.0")

      params = get_default_params
      params["application"] = 'E-Finance'
      params["application_version"] = '1.0.0'

      execute_script_from_module("brpm", "select_application_version", params)

      request_params = get_request_params_manager.get_request_params

      request_params.has_key?("application_version")
      expect(request_params["application_version"]).to eq("2.0.0")

      brpm_client = get_brpm_client

      version_tag = brpm_client.get_version_tag("E-Finance","EF - Java calculation engine", "development", "2.0.0")
      expect(version_tag).not_to be_nil
    end
  end

  before(:each) do
    cleanup_request_data_file
    cleanup_version_tags_for_app("E-Finance")
  end
end