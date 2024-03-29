require_relative "spec_helper"
require "brpm_auto"

describe 'Server yaml' do
  before(:each) do
    cleanup_request_params
  end

  it 'should get the parameters' do
    input_params = get_default_params
    input_params["home_dir"] = "#{File.dirname(__FILE__)}/customer_include"

    BrpmAuto.setup(input_params)

    params = BrpmAuto.global_params

    expect(params).to have_key("key2")
    expect(params["key2"]).to eql("value2")
  end
end