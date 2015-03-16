$LOAD_PATH << File.dirname(__FILE__)

require "framework/lib/logger"

def privatize(expression, sensitive_data)

  unless sensitive_data.nil? or sensitive_data.empty?
    sensitive_data = [sensitive_data] if sensitive_data.kind_of?(String)

    sensitive_data.each do |sensitive_string|
      expression = expression.gsub(sensitive_string, "********")
    end
  end

  expression
end

def exec_command(command, sensitive_data = nil)
  escaped_command = command.gsub("\\", "\\\\")

  loggable_command = privatize(escaped_command, sensitive_data)

  Logger.log loggable_command
  Logger.log `#{escaped_command}`

  exit_status = $?.exitstatus
  unless exit_status == 0
    raise "Command #{loggable_command} exited with #{exit_status}."
  end
end

def sub_tokens(script_params,var_string)
  return var_string if var_string.nil?

  prop_val = var_string.match('rpm{[^{}]*}')
  while ! prop_val.nil? do
    raise "Property #{prop_val[0][4..-2]} doesn't exist" if script_params[prop_val[0][4..-2]].nil?
    var_string = var_string.sub(prop_val[0],script_params[prop_val[0][4..-2]])
    prop_val = var_string.match('rpm{[^{}]*}')
  end
  return var_string
end

def first_defined(first, second)
  if first and ! first.empty?
    return first
  else
    return second
  end
end

def get_scripts_from_git_repo(git_url, git_repo_name, target_directory)
  root_git_repo_dir = "#{target_directory}"
  git_repo_dir = "#{root_git_repo_dir}/#{git_repo_name}"

  Dir.mkdir(root_git_repo_dir) unless Dir.exists?(root_git_repo_dir)

  if Dir.exists?("#{git_repo_dir}/.git")
    Logger.log "Pulling git repository in #{git_repo_dir} ..."
    pwd = Dir.pwd
    Dir.chdir(git_repo_dir)
    exec_command("git checkout .")
    exec_command("git pull")
    Dir.chdir(pwd)
  else
    Dir.mkdir(git_repo_dir) unless Dir.exists?(git_repo_dir)
    Logger.log "git clone #{git_url}/#{git_repo_name}.git #{git_repo_dir} ..."
    exec_command("git clone #{git_url}/#{git_repo_name}.git #{git_repo_dir}")
  end
end

def require_all(directory)
  Dir[directory].each do |file|
    File.expand_path(file)
    if File.file?(file) && !File.expand_path(file).split("/").include?("spec")
      require file
    end
  end
end

def load_all(directory)
  Dir[directory].each do |file|
    File.expand_path(file)
    if File.file?(file) && !File.expand_path(file).split("/").include?("spec")
      load file
    end
  end
end

def get_automation_script_dir(params)
  if params.has_key?("automation_script_dir")
    automation_script_dir = params["automation_script_dir"]
  else
    if params.has_key?("local_debug") && params["local_debug"]=='true'
      target_directory = "/Users/niek/src/bmc"
    else
      target_directory = "#{params["SS_script_support_path"]}/git_repos"
    end

    automation_script_dir = "#{target_directory}/brpm_content"
  end

  $params = params

  automation_script_dir
end

def execute_script_from_module(modul, name, params)
  begin
    Logger.initialize(params)

    Logger.log ""
    Logger.log ">>>>>>>>>>>>>> START automation #{name}"
    start_time = Time.now

    automation_script_dir = "#{get_automation_script_dir(params)}/#{modul}/automations/#{name}"

    Logger.log "Requiring all scripts from #{automation_script_dir}..."
    require_all("#{automation_script_dir}/**/*.rb")

    Logger.log "Calling execute_script(params)..."
    execute_script(params)

  rescue Exception => e
    Logger.log_error "#{e}"
    Logger.log e.backtrace.join("\n\t")

    raise e
  ensure
    stop_time = Time.now
    duration = 0
    duration = stop_time - start_time unless start_time.nil?

    Logger.log ">>>>>>>>>>>>>> STOP automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
    Logger.log ""

    write_to(File.read(Logger.get_step_run_log_file_path)) if defined? write_to
  end
end

def execute_resource_automation_script_from_module(modul, name, params, parent_id, offset, max_records)
  begin
    Logger.initialize(params)

    Logger.log ""
    Logger.log ">>>>>>>>>>>>>> START resource automation #{name}"
    start_time = Time.now

    automation_script_dir = "#{get_automation_script_dir(params)}/#{modul}/resource_automations/#{name}"

    Logger.log "Loading all scripts from #{automation_script_dir}..."
    load_all("#{automation_script_dir}/**/*.rb")

    Logger.log "Calling execute_resource_automation_script(params, parent_id, offset, max_records)..."
    execute_resource_automation_script(params, parent_id, offset, max_records)

  rescue Exception => e
    Logger.log_error "#{e}"
    Logger.log e.backtrace.join("\n\t")

    raise e
  ensure
    stop_time = Time.now
    duration = stop_time - start_time

    Logger.log ">>>>>>>>>>>>>> STOP resource automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
    Logger.log ""

    write_to(File.read(Logger.get_step_run_log_file_path)) if defined? write_to
  end
end