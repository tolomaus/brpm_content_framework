require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Request params' do
  before(:each) do
    cleanup_request_params
  end

  it 'should get a param' do
    input_request_params = {}
    input_request_params["key1"] = "value1"
    set_request_params(input_request_params)

    BrpmAuto.setup(get_default_params)
    request_params = BrpmAuto.request_params

    expect(request_params).to have_key("key1")
    expect(request_params["key1"]).to eql("value1")
  end

  it 'should resolve a tokenized param' do
    input_request_params = {}
    input_request_params["key1"] = "value1"
    input_request_params["tokenized_key"] = "The value is rpm{key1}!"
    set_request_params(input_request_params)

    BrpmAuto.setup(get_default_params)
    request_params = BrpmAuto.request_params

    expect(request_params).to have_key("tokenized_key")
    expect(request_params["tokenized_key"]).to eql("The value is value1!")
  end

  it 'should get a param by the get method' do
    input_request_params = {}
    input_request_params["key1"] = "value1"
    set_request_params(input_request_params)

    BrpmAuto.setup(get_default_params)
    request_params = BrpmAuto.request_params

    expect(request_params).to have_key("key1")
    expect(request_params.get("key1")).to eql("value1")
  end

  it 'should add a param using []=' do
    BrpmAuto.setup(get_default_params)
    request_params = BrpmAuto.request_params

    request_params["key1"] = "value1"

    output_request_params = get_request_params

    expect(output_request_params).to have_key("key1")
    expect(output_request_params["key1"]).to eql("value1")
  end

  it 'should add a param by the add method' do
    BrpmAuto.setup(get_default_params)
    request_params = BrpmAuto.request_params

    request_params.add("key1", "value1")

    output_request_params = get_request_params

    expect(output_request_params).to have_key("key1")
    expect(output_request_params["key1"]).to eql("value1")
  end

  it 'should find or add a param' do
    input_request_params = {}
    input_request_params["key1"] = "value1"
    set_request_params(input_request_params)

    BrpmAuto.setup(get_default_params)
    request_params = BrpmAuto.request_params

    expect(request_params.find_or_add("key1", "value1-bis")).to eql("value1")
    expect(request_params.count).to eql(1)

    expect(request_params.find_or_add("key2", "value2")).to eql("value2")
    expect(request_params.count).to eql(2)
    expect(request_params["key2"]).to eql("value2")
  end
end


