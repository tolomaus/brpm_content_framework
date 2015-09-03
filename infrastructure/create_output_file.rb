require "#{BrpmAuto.params["SS_script_support_path"]}/ssh_script_header.rb"
require "#{BrpmAuto.params["SS_script_support_path"]}/script_helper.rb"
require "#{BrpmAuto.params["SS_script_support_path"]}/file_in_utf.rb"

# this line must be executed before the automation script is run because it sets the @hand variable which will be used inside the BRPM core framework
@hand = FileInUTF.open(BrpmAuto.params["SS_output_file"], "a")
