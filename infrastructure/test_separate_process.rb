require 'bundler/setup';
require 'brpm_script_executor';
BrpmScriptExecutor.execute_automation_script_from_other_process('brpm_module_test', 'test_ruby_raises_error', '/private/tmp/brpm_content/params_000_tmp.yml')