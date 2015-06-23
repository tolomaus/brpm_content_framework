#BRPM Framework Additions
FRAMEWORK_DIR = File.dirname(File.dirname(File.expand_path(__FILE__))) unless defined?(FRAMEWORK_DIR)

def load_helpers(lib_path)
  require "#{lib_path}/script_helper.rb"
  require "#{lib_path}/file_in_utf.rb"
end

# BJB 7/6/2010 Append a user script to the bottom of this one for cap execution
def load_input_params(in_file)
  params = YAML::load(File.open(in_file))
  load_helpers(params["SS_script_support_path"])
  @params = strip_private_flag(params)
  #BJB 11-10-14 Intercept to load framework
  initialize_framework
  @params
end

def initialize_framework
  require File.join(FRAMEWORK_DIR, "brpm_framework.rb")
end
