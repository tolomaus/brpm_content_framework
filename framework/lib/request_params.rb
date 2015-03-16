def request_params_exist?
  File.exist?(get_request_params_file_location)
end

def set_request_params(request_params)
  request_params_file = File.new(get_request_params_file_location, "w")
  request_params_file.puts(request_params.to_json)
  request_params_file.close
end

def add_request_param(key, value)
  request_params = request_params_exist? ? get_request_params : {}
  request_params[key] = value

  set_request_params(request_params)
end

def add_request_param_unless_exist(key, value)
  add_request_param(key, value) unless request_param_exist?(key)
end

def request_param_exist?(key)
  get_request_params.include?(key)
end

def get_request_params
  if request_params_exist?
    json = File.read(get_request_params_file_location)
    request_params = JSON.parse(json)
  else
    request_params = {}
  end
  request_params
end

def get_request_params_file_location
  request_params_dir = File.expand_path("..", $params["SS_output_dir"])

  "#{request_params_dir}/request_data.json"
end

def get_request_params_of_request(app_name, request_id)
  if request_params_exist?
    json = File.read("#{$params["SS_automation_results_dir"]}/request/#{app_name}/#{request_id}")
    request_params = JSON.parse(json)
  else
    request_params = {}
  end
  request_params
end
