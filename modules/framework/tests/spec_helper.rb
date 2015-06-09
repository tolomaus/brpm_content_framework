require 'fileutils'
require "#{File.dirname(__FILE__)}/../brpm_auto"

def setup_brpm_auto
  FileUtils.mkdir_p "/tmp/brpm_content"

  BrpmAuto.setup( { "output_dir" => "/tmp/brpm_content" } )
end

def get_default_params
  params = {}
  params['also_log_to_console'] = 'true'
  params['output_dir'] = "/tmp/brpm_content"

  params
end
