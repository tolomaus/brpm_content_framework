require_relative "spec_helper"

describe 'BRPM Script Executor' do
  before(:all) do
    setup_gem_env

    require_relative "../lib/brpm_script_executor"
    require_relative "../lib/brpm_auto"
    BrpmAuto.setup(get_default_params)

    ENV["GEM_HOME"] = "#{ENV["BRPM_HOME"]}/modules"
    Gem.paths = ENV
    test_gems = Gem::Specification.find_all_by_name("brpm_module_test")

    if test_gems.empty?
      # TODO: get this to work to avoid race conditions waiting for the new gem version to be 'rake release'ed to rubygems
      # BrpmAuto.log "Doing a 'rake install' to install brpm_content_framework as a gem..."
      # result = Bundler.clean_system("export GEM_HOME=#{ENV["GEM_HOME"]} && cd .. && rake install")
      # raise "rake install failed" unless result

      BrpmAuto.log "Installing brpm_module_test..."
      specs = Gem.install("brpm_module_test")
      spec = specs.find { |spec| spec.name == "brpm_module_test"}
      BrpmAuto.log "Bundle install..."
      result = Bundler.clean_system("export GEM_HOME=#{ENV["GEM_HOME"]} && export BUNDLE_GEMFILE=#{spec.gem_dir}/Gemfile && bundle install")
      raise "bundle install failed" unless result
    end
  end

  # these tests have to be executed outside bundler because they need the gem brpm_module_test which is not included in the Gemfile of brpm_content_framework
  it "should execute an automation script in-process" do
    expect{BrpmScriptExecutor.execute_automation_script("brpm_module_test", "test_ruby", get_default_params)}.not_to raise_exception
  end

  it "should return false when executing an non-existing automation script in-process" do
    expect{BrpmScriptExecutor.execute_automation_script("brpm_module_test", "xxx", get_default_params)}.to raise_exception
  end

  it "should return false when executing an erroneous automation script in-process" do
    expect{BrpmScriptExecutor.execute_automation_script("brpm_module_test", "test_ruby_raises_error", get_default_params)}.to raise_exception
  end
end