require 'fileutils'
require_relative "../brpm_auto"

FileUtils.mkdir_p "/tmp/brpm_content"

def setup_brpm_auto
  BrpmAuto.setup(get_default_params)
end

def get_default_params
  params = {}
  params['also_log_to_console'] = 'true'
  params['output_dir'] = "/tmp/brpm_content"

  params
end

def set_request_params(request_params)
  File.open("/tmp/brpm_content/request_data.json", "w") do |file|
    file.puts(request_params.to_json)
  end
end

def get_request_params
  if File.exist?("/tmp/brpm_content/request_data.json")
    json = File.read("/tmp/brpm_content/request_data.json")
    JSON.parse(json)
  else
    {}
  end
end

def cleanup_request_params
  request_params_file = "/tmp/brpm_content/request_data.json"
  File.delete(request_params_file) if File.exist?(request_params_file)
end

def decrypt_string_with_prefix(input) # mocked method
  return nil if input.nil? || !input.kind_of?(String)

  input.gsub("_encrypted", "")
end
