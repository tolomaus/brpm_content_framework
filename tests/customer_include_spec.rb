require_relative "spec_helper"
require "brpm_auto"

describe 'Customer include' do
  before(:each) do
    cleanup_request_params
  end

  it 'should get the parameters' do
    input_params = get_default_params
    input_params["home_dir"] = "#{File.dirname(__FILE__)}/customer_include"

    BrpmAuto.setup(input_params)

    params = BrpmAuto.params

    expect(params).to have_key("key1")
    expect(params["key1"]).to eql("value1")
  end

  it 'should execute a custom method' do
    input_params = get_default_params
    input_params["home_dir"] = "#{File.dirname(__FILE__)}/customer_include"

    BrpmAuto.setup(input_params)

    expect(defined?(my_custom_method)).to eql("method")
    expect(my_custom_method("a", "b")).to eql("ab")
  end
end