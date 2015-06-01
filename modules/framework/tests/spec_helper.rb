require 'fileutils'

FileUtils.mkdir_p "/tmp/brpm_content"

def get_default_params
  params = {}
  params['also_log_to_console'] = 'true'
  params['output_dir'] = "/tmp/brpm_content"

  params
end
