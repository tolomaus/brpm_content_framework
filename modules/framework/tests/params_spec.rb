require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Params' do
  before(:each) do
    cleanup_request_params
  end

  it 'should get a param' do
    input_params = get_default_params
    input_params["key1"] = "value1"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params).to have_key("key1")
    expect(params["key1"]).to eql("value1")
  end

  it 'should resolve a tokenized param' do
    input_params = get_default_params
    input_params["key1"] = "value1"
    input_params["tokenized_key"] = "The value is rpm{key1}!"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params).to have_key("tokenized_key")
    expect(params["tokenized_key"]).to eql("The value is value1!")
  end

  it 'should get a param via its dedicated method' do
    input_params = get_default_params
    input_params["request_id"] = "123456"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params.request_id).to eql("123456")
  end

  it 'should get the servers' do
    input_params = get_default_params

    input_params["server1000_name"] = "server1"
    input_params["server1001_dns"] = "server1.com"
    input_params["server1002_ip_address"] = "192.168.1.1"
    input_params["server1003_os_platform"] = "linux"

    input_params["server2000_name"] = "server2"
    input_params["server2001_dns"] = "server2.com"
    input_params["server2002_ip_address"] = "192.168.1.2"
    input_params["server2003_os_platform"] = "linux"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params.servers.count).to eql(2)

    expect(params.servers).to have_key("server1")

    expect(params.servers["server1"]).to have_key("dns")
    expect(params.servers["server1"]["dns"]).to eql("server1.com")
    expect(params.servers["server1"]).to have_key("ip_address")
    expect(params.servers["server1"]["ip_address"]).to eql("192.168.1.1")
    expect(params.servers["server1"]).to have_key("os_platform")
    expect(params.servers["server1"]["os_platform"]).to eql("linux")

    expect(params.servers).to have_key("server2")
  end

  it 'should get the servers by os platform' do
    input_params = get_default_params

    input_params["server1000_name"] = "server1"
    input_params["server1003_os_platform"] = "linux"

    input_params["server2000_name"] = "server2"
    input_params["server2003_os_platform"] = "linux"

    input_params["server3000_name"] = "server3"
    input_params["server3003_os_platform"] = "windows"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    linux_servers = params.get_servers_by_os_platform("linux")
    expect(linux_servers.count).to eql(2)

    windows_servers = params.get_servers_by_os_platform("windows")
    expect(windows_servers.count).to eql(1)

    windows_servers = params.get_servers_by_os_platform("xxx")
    expect(windows_servers.count).to eql(0)
  end

  it 'should get a server property' do
    input_params = get_default_params

    input_params["server1000_name"] = "server1"
    input_params["server1003_property1"] = "value1"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params.get_server_property("server1", "property1")).to eql("value1")
  end

  it 'should get an encrypted param' do
    input_params = get_default_params
    input_params["run_key"] = "123" #trick it into thinking that it is run from BRPM
    input_params["key1_encrypt"] = "brpm_encrypted"
    input_params["key2_enc"] = "brpm_encrypted"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params["key1"]).to eql("brpm")
    expect(params["key2"]).to eql("brpm")
  end

  it 'should get a param by the get method' do
    input_params = get_default_params
    input_params["key1"] = "value1"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params.get("key1")).to eql("value1")
  end

  it 'should add a param by the add method' do
    BrpmAuto.setup(get_default_params)
    params = BrpmAuto.params

    params.add("key1", "value1")

    expect(params["key1"]).to eql("value1")
  end

  it 'should find or add a param' do
    input_params = get_default_params
    input_params["key1"] = "value1"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params.find_or_add("key1", "value1-bis")).to eql("value1")
    expect(params.count).to eql(input_params.count)

    expect(params.find_or_add("key2", "value2")).to eql("value2")
    expect(params.count).to eql(input_params.count + 1)
    expect(params["key2"]).to eql("value2")
  end

  it 'should calculate the REST request id' do
    input_params = get_default_params
    input_params["request_id"] = "1234"

    BrpmAuto.setup(input_params)
    params = BrpmAuto.params

    expect(params.rest_request_id).to eql("234")
  end
end


