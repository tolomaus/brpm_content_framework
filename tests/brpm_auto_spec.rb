require_relative "spec_helper"

describe 'BRPM automation framework' do
  before(:all) do
    setup_brpm_auto
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

  describe 'execute_shell' do
    it 'should execute a command successfully' do
      result = BrpmAuto.execute_shell("echo Hello")

      expect(result["status"]).to eql(0)
      expect(result["stdout"].chomp).to eql("Hello")
    end

    it 'should return with a non-zero status when passing a bad command' do
      result = BrpmAuto.execute_shell("xxxx")

      expect(result["status"]).not_to eql(0)
    end
  end

  describe 'execute_shell_stream_logs' do
    it 'should execute a command successfully' do
      stdout, _, _, status = BrpmAuto.execute_command("echo Hello")

      expect(status.success?).to be_truthy
      expect(stdout.chomp).to eql("Hello")
    end

    it 'should execute a command successfully and stream the stdout' do
      streamed_logs = ""
      _, _, _, status = BrpmAuto.execute_command("echo Hello") do |stdout_err|
        streamed_logs += stdout_err
      end

      expect(status.success?).to be_truthy
      expect(streamed_logs.chomp).to eql("Hello")
    end

    it 'should return with a non-zero status when passing a command that raises an exception and stream the stderr' do
      _, stderr, _, status = BrpmAuto.execute_command("ruby -e \"raise 'Boom'\"")

      expect(status.success?).to be_falsey
      expect(stderr.chomp).to eql("-e:1:in `<main>': Boom (RuntimeError)")
    end

    it 'should return with a non-zero status when passing a bad command' do
      expect { BrpmAuto.execute_command("xxxx") }.to raise_exception
    end
  end
end


