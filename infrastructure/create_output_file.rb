if BrpmAuto.params["SS_run_key"] and BrpmAuto.params["SS_script_support_path"]
  puts "Loading script_support libraries..."
  require "#{params["SS_script_support_path"]}/ssh_script_header.rb"
  require "#{params["SS_script_support_path"]}/script_helper.rb"
  require "#{params["SS_script_support_path"]}/file_in_utf.rb"
end

# this line must be executed before the automation script is run because it sets the @hand variable which will be used inside the BRPM core framework
@hand = FileInUTF.open(BrpmAuto.params["SS_output_file"], "a")
