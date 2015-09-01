require_relative "spec_helper"
require "brpm_auto"

describe 'All params' do
  before(:each) do
    cleanup_request_params
  end

  it 'should get a param from the param store' do
    input_params = get_default_params
    input_params["key1"] = "value1"

    BrpmAuto.setup(input_params)
    all_params = BrpmAuto.all_params

    expect(all_params).to have_key("key1")
    expect(all_params["key1"]).to eql("value1")
  end

  it 'should get a param from the request_param store' do
    input_params = get_default_params
    input_params["key1"] = "value1"

    BrpmAuto.setup(input_params)
    all_params = BrpmAuto.all_params

    expect(all_params).to have_key("key1")
    expect(all_params["key1"]).to eql("value1")
  end

  it 'should get a param by the get method' do
    input_params = get_default_params
    input_params["key1"] = "value1"

    BrpmAuto.setup(input_params)
    all_params = BrpmAuto.all_params

    expect(all_params).to have_key("key1")
    expect(all_params.get("key1")).to eql("value1")
  end

  it 'should raise an error when trying to add a param using []=' do
    BrpmAuto.setup(get_default_params)
    all_params = BrpmAuto.all_params

    expect{ all_params["key1"] = "value1" }.to raise_exception(RuntimeError)
  end

  it 'should add a param by the add method to the params store' do
    input_params = get_default_params

    BrpmAuto.setup(input_params)
    all_params = BrpmAuto.all_params

    all_params.add("key1", "value1", "params")

    expect(all_params).to have_key("key1")
    expect(all_params["key1"]).to eql("value1")
    expect(all_params.count).to eql(get_default_params.count + 1)

    expect(BrpmAuto.params.count).to eql(all_params.count)

    request_params = get_request_params
    expect(request_params.count).to eql(0)
  end

  it 'should add a param by the add method to the request_param store' do
    input_params = get_default_params
    BrpmAuto.setup(input_params)
    all_params = BrpmAuto.all_params

    all_params.add("key1", "value1", "json")

    expect(all_params).to have_key("key1")
    expect(all_params["key1"]).to eql("value1")
    expect(all_params.count).to eql(input_params.count + 1)

    expect(BrpmAuto.params.count).to eql(all_params.count - 1)

    request_params = get_request_params
    expect(request_params.count).to eql(1)
  end

  it 'should find or add a param to the params store' do
    input_params = get_default_params
    input_params["key1"] = "value1"

    BrpmAuto.setup(input_params)
    all_params = BrpmAuto.all_params

    expect(all_params.find_or_add("key1", "value1-bis", "params")).to eql("value1")
    expect(all_params.count).to eql(input_params.count)

    expect(all_params.find_or_add("key2", "value2", "params")).to eql("value2")
    expect(all_params.count).to eql(input_params.count + 1)
    expect(all_params["key2"]).to eql("value2")
  end

  it 'should find or add a param to the request_params store' do
    input_request_params = {}
    input_request_params["key1"] = "value1"
    set_request_params(input_request_params)

    input_params = get_default_params
    BrpmAuto.setup(input_params)
    all_params = BrpmAuto.all_params

    expect(all_params.find_or_add("key1", "value1-bis", "json")).to eql("value1")
    expect(all_params.count).to eql(input_params.count + 1)

    expect(all_params.find_or_add("key2", "value2", "json")).to eql("value2")
    expect(all_params.count).to eql(input_params.count + 2)
    expect(all_params["key2"]).to eql("value2")
  end
end


