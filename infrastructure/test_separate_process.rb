require 'bundler/setup';
require 'brpm_script_executor';
BrpmScriptExecutor.execute_automation_script_from_other_process('brpm_module_test', 'test_ruby', '/private/tmp/brpm_content/params_000.yml', "automation")