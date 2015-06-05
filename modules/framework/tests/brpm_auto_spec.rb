require "#{File.dirname(__FILE__)}/spec_helper"

describe 'privatize' do
  before(:all) do
    BrpmAuto.setup( get_default_params )
  end

  it 'should work' do
    params = get_default_params

    params["application"] = 'E-Finance'
    params["component"] = 'EF - Java calculation engine'
    params["component_version"] = '1.0.0'
  end
end

