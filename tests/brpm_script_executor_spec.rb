require_relative "spec_helper"
require "fileutils"

describe 'BRPM Script Executor' do
  before(:all) do
    setup_brpm_env

    require_relative "../lib/brpm_script_executor"
    require_relative "../lib/brpm_auto"
    BrpmAuto.setup(get_default_params)

    @module_name = "brpm_module_test"
    # We are running inside bundler and the brpm_module_test is not specified in it so don't use the Gem methods
    test_gems = Dir.glob("#{ENV["BRPM_HOME"]}/modules/gems/#{@module_name}*")

    if test_gems.empty?
      # watch out we are running inside bundler, known for messing up the gem configs, so explicitly set the GEM_HOME env var
      ENV["GEM_HOME"] = "#{ENV["BRPM_HOME"]}/modules"
      Gem.paths = ENV

      # TODO: get this to work to avoid race conditions waiting for the new gem version to be 'rake release'ed to rubygems
      # BrpmAuto.log "Doing a 'rake install' to install brpm_content_framework as a gem..."
      # result = Bundler.clean_system("export GEM_HOME=#{ENV["GEM_HOME"]} && cd .. && rake install")
      # raise "rake install failed" unless result

      BrpmAuto.log "Installing #{@module_name}..."
      specs = Gem.install("brpm_module_test")
      spec = specs.find { |spec| spec.name == @module_name}
      BrpmAuto.log "Bundle install..."
      result = Bundler.clean_system("export GEM_HOME=#{ENV["GEM_HOME"]} && export BUNDLE_GEMFILE=#{spec.gem_dir}/Gemfile && bundle install")
      raise "bundle install failed" unless result
    end
  end

  # Note: the following tests will run the automation scripts in a separate process and will therefore use an already installed brpm_content_framework module,
  # either the version from their Gemfile/Gemfile.lock or the latest, but not the one from source code
  it "should execute an automation script in a separate process inside a bundler context" do
    result = BrpmScriptExecutor.execute_automation_script_in_separate_process("brpm_module_test", "test_ruby", get_default_params)

    expect(result).to be_truthy
  end

  it "should execute an automation script in a separate process outside a bundler context" do
    module_version = BrpmScriptExecutor.get_latest_installed_version(@module_name)
    module_gem_path = BrpmScriptExecutor.get_module_gem_path(@module_name, module_version)
    gemfile_path = "#{module_gem_path}/Gemfile"

    FileUtils.move(gemfile_path, "#{gemfile_path}_tmp")
    result = BrpmScriptExecutor.execute_automation_script_in_separate_process(@module_name, "test_ruby", get_default_params)
    FileUtils.move("#{gemfile_path}_tmp", gemfile_path)

    expect(result).to be_truthy
  end

  it "should execute an automation script in a docker container" do
    params = get_default_params
    params['output_dir'] = File.expand_path("~/tmp/brpm_content") # docker volume mappong only works from the current user's home directory on Mac OSX
    params["execute_automation_scripts_in_docker"] = "always"

    result = BrpmScriptExecutor.execute_automation_script_in_separate_process("brpm_module_test", "test_ruby", params)

    expect(result).to be_truthy
  end

  it "should return false when executing an non-existing automation script in a separate process" do
    expect{BrpmScriptExecutor.execute_automation_script_in_separate_process(@module_name, "xxx", get_default_params)}.to raise_exception
  end

  it "should return false when executing an erroneous automation script in a separate process" do
    expect{BrpmScriptExecutor.execute_automation_script_in_separate_process(@module_name, "test_ruby_raises_error", get_default_params)}.to raise_exception
  end

  it "should execute a resource automation script in a separate process" do
    result = BrpmScriptExecutor.execute_resource_automation_script_in_separate_process(@module_name, "test_resource", get_default_params, nil, 0, 10)

    expect(result.count).to eql(3)
  end

  xit "should execute a resource automation script in a docker container" do
    params = get_default_params
    params['output_dir'] = File.expand_path("~/tmp/brpm_content") # docker volume mappong only works from the current user's home directory on Mac OSX
    params["execute_automation_scripts_in_docker"] = "always"

    result = BrpmScriptExecutor.execute_resource_automation_script_in_separate_process(@module_name, "test_resource", params, nil, 0, 10)

    expect(result.count).to eql(3)
  end
end