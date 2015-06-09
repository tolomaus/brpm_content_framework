require "#{File.dirname(__FILE__)}/spec_helper"

describe 'BRPM automation framework' do
  before(:all) do
    setup_brpm_auto
  end

  describe 'exec_command' do
    it 'should execute a command successfully' do
      result = BrpmAuto.exec_command("echo Hello")

      expect(result).to eql("Hello")
    end
  end

  describe 'privatize' do
    it 'should hide a sensitive string' do
      result = BrpmAuto.privatize("The password should be replaced here: MySecret, and also here:MySecret! ", "MySecret")

      expect(result).not_to include("MySecret")
      expect(result).to include("The password should be replaced here: ")
      expect(result).to include(", and also here:")
      expect(result).to include("! ")
    end

    it 'should hide an array of sensitive strings' do
      privatized_string = BrpmAuto.privatize("The password should be replaced here: MySecret, and also here:MyOtherSecret! ", [ "MySecret", "MyOtherSecret" ])

      expect(privatized_string).not_to include("MySecret")
      expect(privatized_string).not_to include("MyOtherSecret")
      expect(privatized_string).to include("The password should be replaced here: ")
      expect(privatized_string).to include(", and also here:")
      expect(privatized_string).to include("! ")
    end
  end

  describe 'substitute_tokens' do
    it 'should replace a token' do
      params = {}
      params["application"] = "E-Finance"
      result = BrpmAuto.substitute_tokens("The application is called rpm{application}", params)

      expect(result).to eq("The application is called E-Finance")
    end

    it 'should replace a set of tokens' do
      params = {}
      params["application"] = "E-Finance"
      params["component"] = "EF - java calculation engine"
      params["component_version"] = "1.2.3"
      result = BrpmAuto.substitute_tokens("The application is called rpm{application} and has component rpm{component} with version number rpm{component_version}", params)

      expect(result).to eq("The application is called E-Finance and has component EF - java calculation engine with version number 1.2.3")
    end

    it 'should replace a set of nested tokens' do
      params = {}
      params["application"] = "E-Finance"
      params["component"] = "EF - java calculation engine"
      params["component_version"] = "1.2.rpm{component_version_revision}"
      params["component_version_revision"] = "3"
      result = BrpmAuto.substitute_tokens("The application is called rpm{application} and has component rpm{component} with version number rpm{component_version}", params)

      expect(result).to eq("The application is called E-Finance and has component EF - java calculation engine with version number 1.2.3")
    end
  end

  describe 'dos_path' do
    it 'should convert a path from the UNIX to the Windows format' do
      result = BrpmAuto.dos_path("C/windows/path")

      expect(result).to eq("C:\\windows\\path")
    end
  end
end


