require_relative "spec_helper"

describe 'BRPM Script Executor' do
  before(:all) do
    setup_brpm_env

    require_relative "../lib/brpm_script_executor"
    require_relative "../lib/brpm_auto"
    BrpmAuto.refresh_gems_root_path # TODO: find a better way to make sur ethe newly set BRPM_HOME is taken into account in cases where BrpmAuto was already loaded during earlier tests without the BRPM_HOME set
    BrpmAuto.setup(get_default_params)

    test_gems = Dir.glob("#{ENV["BRPM_HOME"]}/modules/gems/brpm_module_test*")

    if test_gems.empty?
      # watch out we are running inside bundler, known for messing up the gem configs
      ENV["GEM_HOME"] = "#{ENV["BRPM_HOME"]}/modules"
      Gem.paths = ENV

      BrpmAuto.log "Installing brpm_module_test..."
      specs = Gem.install("brpm_module_test")
      spec = specs.find { |spec| spec.name == "brpm_module_test"}
      BrpmAuto.log "Bundle install..."
      `export GEM_HOME=#{ENV["GEM_HOME"]}; export BUNDLE_GEMFILE=#{spec.gem_dir}/Gemfile; bundle install`
    end
  end

  it "should execute an automation script in-process" do
    result = BrpmScriptExecutor.execute_automation_script("brpm_module_test", "test_ruby", get_default_params)

    expect(result).to be_truthy
  end

  it "should return false when executing an non-existing automation script in-process" do
    expect{BrpmScriptExecutor.execute_automation_script("brpm_module_test", "xxx", get_default_params)}.to raise_exception
  end

  it "should return false when executing an erroneous automation script in-process" do
    expect{BrpmScriptExecutor.execute_automation_script("brpm_module_test", "test_ruby_raises_error", get_default_params)}.to raise_exception
  end

  it "should execute an automation script in a separate process" do
    result = BrpmScriptExecutor.execute_automation_script_in_separate_process("brpm_module_test", "test_ruby", get_default_params)

    expect(result).to be_truthy
  end

  it "should return false when executing an non-existing automation script in a separate process" do
    result = BrpmScriptExecutor.execute_automation_script_in_separate_process("brpm_module_test", "xxx", get_default_params)

    expect(result).to be_falsey
  end

  it "should return false when executing an erroneous automation script in a separate process" do
    result = BrpmScriptExecutor.execute_automation_script_in_separate_process("brpm_module_test", "test_ruby_raises_error", get_default_params)

    expect(result).to be_falsey
  end
end