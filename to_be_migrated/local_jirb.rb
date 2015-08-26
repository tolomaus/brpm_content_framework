require 'fileutils'
rlm_base_path = "/Users/brady/Documents/dev_rpm/brpm_brady/brpm/branches/rpm-sustaining/Portal"
#rlm_base_path = "/opt/bmc/rlm4"
script_support = "#{rlm_base_path}/lib/script_support"
persist = "/Users/brady/Documents/dev_rpm/brpm_content/modules/framework"
FileUtils.cd script_support, :verbose => true
require "#{script_support}/ssh_script_header"

input_file = "#{rlm_base_path}/public/automation_results/request/Sales-Billing/1304/step_3722/sshinput_6_1433379304.txt"

script_params = params = load_input_params(input_file)
Token = "a56d64cbcffcce91d306670489fa4cf51b53316c"

require "#{persist}/brpm_framework.rb"
@rest = BrpmRest.new(@rpm.params.brpm_url)