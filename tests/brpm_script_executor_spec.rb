require_relative "spec_helper"

describe 'BRPM Script Executor' do
  before(:all) do
    setup_brpm_env

    require_relative "../lib/brpm_script_executor"
    require_relative "../lib/brpm_auto"
    BrpmAuto.setup(get_default_params)

    BrpmAuto.log "Creating ~/.brpm file..."
    create_brpm_file

    gem_installed = `gem list -i brpm_module_test`.chomp
    if gem_installed != "true" # we are running inside bundler here so simplest to install the gem using a separate process
      BrpmAuto.log "Installing brpm_module_test..."
      # `gem install brpm_module_test`
    end
  end

  it "should execute an automation script in a separate process" do
    result = BrpmScriptExecutor.execute_automation_script_in_separate_process("brpm_module_test", "test_ruby", get_default_params)

    expect(result).to be_truthy
  end
end