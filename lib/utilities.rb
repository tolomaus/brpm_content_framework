require 'rbconfig'
require 'open3'

module Utilities
  EXIT_CODE_FAILURE = 'Exit_Code_Failure'

  def is_windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/i
  end

  def is_jruby?

    RbConfig::CONFIG['ruby_install_name'] =~ /jruby/i
  end

  # Returns the dos path from a standard path
  #
  # ==== Attributes
  #
  # * +source_path+ - path in standard "/" format
  # * +drive_letter+ - base drive letter if not included in path (defaults to C)
  #
  # ==== Returns
  #
  # * dos compatible path
  #
  def dos_path(source_path, drive_letter = "C")
    path = ""
    return source_path.gsub("/", "\\") if source_path.include?(":\\")
    path_array = source_path.split("/")
    if path_array[1].length == 1 # drive letter
      path = "#{path_array[1]}:\\"
      path += path_array[2..-1].join("\\")
    else
      path = "#{drive_letter}:\\"
      path += path_array[1..-1].join("\\")
    end
    path
  end

  # Executes a command via shell
  #
  # ==== Attributes
  #
  # * +command+ - command to execute on command line
  # ==== Returns
  #
  # * command_run hash {stdout => <results>, stderr => any errors, pid => process id, status => exit_code}
  def execute_shell(command, sensitive_data = nil)
    escaped_command = command.gsub("\\", "\\\\")

    loggable_command = BrpmAuto.privatize(escaped_command, sensitive_data)
    BrpmAuto.log "Executing '#{loggable_command}'..."

    cmd_result = {"stdout" => "","stderr" => "", "pid" => "", "status" => 1}

    output_dir = File.join(BrpmAuto.params.output_dir,"#{precision_timestamp}")
    errfile = "#{output_dir}_stderr.txt"
    complete_command = "#{escaped_command} 2>#{errfile}" unless is_windows?
    fil = File.open(errfile, "w+")
    fil.close

    begin
      cmd_result["stdout"] = `#{complete_command}`
      status = $?
      cmd_result["pid"] = status.pid
      cmd_result["status"] = status.to_i

      fil = File.open(errfile)
      stderr = fil.read
      fil.close

      if stderr.length > 2
        BrpmAuto.log "Command generated an error: #{stderr}"
        cmd_result["stderr"] = stderr
      end
    rescue Exception => e
      BrpmAuto.log "Command generated an error: #{e.message}"
      BrpmAuto.log "Back trace:\n#{e.backtrace}"

      cmd_result["status"] = -1
      cmd_result["stderr"] = "ERROR\n#{e.message}"
    end

    File.delete(errfile)

    cmd_result
  end

  def execute_command(command)
    *commands=command
    if is_jruby? #TODO work around for buggy jruby implementation of popen3
      *commands = RbConfig::CONFIG['SHELL'], is_windows? ? "?C" : "-c", command
    end
    Open3.popen3(*commands) do |stdin, stdout, stderr, thread|
      logs = {:out => "", :err => ""}

      if block_given?
        { :out => stdout, :err => stderr }.each do |key, stream|
          Thread.new do
            while line = stream.gets
              privatized_line = BrpmAuto.privatize(line)
              logs[key] += privatized_line
              yield privatized_line
            end
          end if block_given?
        end

        thread.join
      else
        logs[:out] = stdout.read
        logs[:err] = stderr.read
      end

      return logs[:out], logs[:err], thread.pid, thread.value
    end
  end

  # Returns a timestamp to the thousanth of a second
  #
  # ==== Returns
  #
  # string timestamp 20140921153010456
  #
  def precision_timestamp
    Time.now.strftime("%Y%m%d%H%M%S%L")
  end

  # Provides a simple failsafe for working with hash options
  # returns "" if the option doesn't exist or is blank
  # ==== Attributes
  #
  # * +options+ - the hash
  # * +key+ - key to find in options
  # * +default_value+ - if entered will be returned if the option doesn't exist or is blank
  def get_option(options, key, default_value = "")
    result = options.has_key?(key) ? options[key] : nil
    result = default_value if result.nil? || result == ""
    result
  end

  # Throws an error if an option is missing
  #  great for checking if properties exist
  #
  # ==== Attributes
  #
  # * +options+ - the options hash
  # * +key+ - key to find
  def required_option(options, key)
    result = get_option(options, key)
    raise ArgumentError, "Missing required option: #{key}" if result == ""
    result
  end

  # Splits the server and path from an nsh path
  # returns same path if no server prepended
  # ==== Attributes
  #
  # * +path+ - nsh path
  # ==== Returns
  #
  # array [server, path] server is blank if not present
  #
  def split_nsh_path(path)
    result = ["",path]
    result[0] = path.split("/")[2] if path.start_with?("//")
    result[1] = "/#{path.split("/")[3..-1].join("/")}" if path.start_with?("//")
    result
  end

  # Reads the Shebang in a shell script
  # Supports deep format which can include wrapper information
  # ==== Attributes
  #
  # * +os_platform+ - windows or linux
  # * +action_txt+ - the body of the shell script (action)
  # ==== Returns
  #
  # shebang hash e.g. {"ext" => ".bat", "cmd" => "cmd /c", "shebang" => "#![.bat]cmd /c "}
  #
  def read_shebang(os_platform, action_txt)
    if os_platform.downcase =~ /win/
      result = {"ext" => ".bat", "cmd" => "cmd /c", "shebang" => ""}
    else
      result = {"ext" => ".sh", "cmd" => "/bin/bash ", "shebang" => ""}
    end
    if action_txt.include?("#![") # Custom shebang
      shebang = action_txt.scan(/\#\!.*/).first
      result["shebang"] = shebang
      items = shebang.scan(/\#\!\[.*\]/)
      if items.size > 0
        ext = items[0].gsub("#![","").gsub("]","")
        result["ext"] = ext if ext.start_with?(".")
        result["cmd"] = shebang.gsub(items[0],"").strip
      else
        result["cmd"] = shebang
      end
    elsif action_txt.include?("#!/") # Basic shebang
      result["shebang"] = "standard"
    else # no shebang
      result["shebang"] = "none"
    end
    result
  end

  # Takes the command result from run command and build a pretty display
  #
  # ==== Attributes
  #
  # * +cmd_result+ - the command result hash
  # ==== Returns
  #
  # * formatted text
  def display_result(cmd_result)
    result = "Process: #{cmd_result["pid"]}\nSTDOUT:\n#{cmd_result["stdout"]}\n"
    result = "STDERR:\n #{cmd_result["stderr"]}\n#{result}" if cmd_result["stderr"].length > 2
    result += "#{EXIT_CODE_FAILURE} Command returned: #{cmd_result["status"]}" if cmd_result["status"] != 0
    result
  end

  # Looks for terms in the results and builds an exit message
  # returns status message with "Command_Failed if the status fails"
  # ==== Attributes
  # * +results+ - the text to analyze for success
  # * +success_terms+ - the term or terms (use | or & for and and or with multiple terms)
  # * +fail_now+ - if set to true will throw an error if a term is not found
  # ==== Returns
  # * +text+ - summary of success terms
  #
  def verify_success_terms(results, success_terms, fail_now = false, quiet = false)
    results.split("\n").each{|line| exit_status = line if line.start_with?("EXIT_CODE:") }
    if success_terms != ""
      exit_status = []
      c_type = success_terms.include?("|") ? "or" : "and"
      success = [success_terms] if !success_terms.include?("|") || !success_terms.include?("&")
      success = success_terms.split("|") if success_terms.include?("|")
      success = success_terms.split("&") if success_terms.include?("&")
      success.each do |term|
        if results.include?(term)
          exit_status << "Success - found term: #{term}"
        else
          exit_status << "Command_Failed: term not found: #{term}"
        end
      end
      status = exit_status.join(", ")
      status.gsub!("Command_Failed:", "") if status.include?("Success") if c_type == "or"
    else
      status = "Success (because nothing was tested)"
    end
    log status unless quiet
    raise "ERROR: success term not found" if fail_now && status.include?("Command_Failed")
    status
  end

  # Checks/Creates a staging directory
  # 
  # ==== Attributes
  #
  # * +force+ - forces creation of the path if it doesnt exist
  # ==== Returns
  #
  # staging path or ERROR_ if force is false and path does not exist
  #  
  def get_staging_dir(version, force = false)
    staging_path = defined?(RPM_STAGING_PATH) ? RPM_STAGING_PATH : File.join(BrpmAuto.all_params["SS_automation_results_dir"],"staging")
    pattern = File.join(staging_path, "#{Time.now.year.to_s}", path_safe(get_param("SS_application")), path_safe(get_param("SS_component")), path_safe(version))
    if force
      FileUtils.mkdir_p(pattern)
    else
      return pattern if File.exist?(pattern) # Cannot stage the same files twice
      return "ERROR_#{pattern}"
    end
    pattern
  end
  
  # Returns a version of the string safe for a filname or path
  def path_safe(txt)
    txt.gsub(" ", "_").gsub(/\,|\[|\]/,"")
  end

  # DEPRECATED - use substitute_tokens instead (token has the format rpm{MY_TOKEN} instead of $${MY_TOKEN} to avid interference with shell variables)
  def get_keyword_items(script_content = nil)
    result = {}
    content = script_content unless script_content.nil?
    content = File.open(BrpmAuto.all_params["SS_script_file"]).read if script_content.nil?
    KEYWORD_SWITCHES.each do |keyword|
      reg = /\$\$\{#{keyword}\=.*\}\$\$/
      items = content.scan(reg)
      items.each do |item|
        result[keyword] = item.gsub("$${#{keyword}=","").gsub("}$$","").chomp("\"").gsub(/^\"/,"")
      end
    end
    result
  end

  def privatize(expression, sensitive_data = BrpmAuto.params.private_params.values)
    unless sensitive_data.nil? or sensitive_data.empty?
      sensitive_data = [sensitive_data] if sensitive_data.kind_of?(String)

      sensitive_data.each do |sensitive_string|
        expression = expression.gsub(sensitive_string, "********")
      end
    end

    expression
  end

  def substitute_tokens(expression, params = nil)
    return expression if expression.nil? || !expression.kind_of?(String)

    searchable_params = params || @all_params

    found_token = expression.match('rpm{[^{}]*}')
    while ! found_token.nil? do
      raise "Property #{found_token[0][4..-2]} doesn't exist" if searchable_params[found_token[0][4..-2]].nil?
      expression = expression.sub(found_token[0],searchable_params[found_token[0][4..-2]])
      found_token = expression.match('rpm{[^{}]*}')
    end
    return expression
  end

  def first_defined(first, second)
    if first and ! first.empty?
      return first
    else
      return second
    end
  end

  def replace_in_file(file_path, pattern, replacement)
    file_content = File.read(file_path)

    File.open(file_path, "w") do |file|
      file << file_content.gsub(pattern, replacement)
    end
  end

  private

    #TODO: still needed? the framework's error handling should take care of this already
    def exit_code_failure
      return "" if is_windows?
      size_ = EXIT_CODE_FAILURE.size
      exit_code_failure_first_part  = EXIT_CODE_FAILURE[0..3]
      exit_code_failure_second_part = EXIT_CODE_FAILURE[4..size_]
      BrpmAuto.all_params['ignore_exit_codes'] == 'yes' ?
          '' :
          "; if [ $? -ne 0 ]; then first_part=#{exit_code_failure_first_part}; echo \"${first_part}#{exit_code_failure_second_part}\"; fi;"
    end

    def url_encode(name)
      name.gsub(" ","%20").gsub("/","%2F").gsub("?","%3F")
    end

    def touch_file(file_path)
      fil = File.open(file_path,"w+")
      fil.close
      file_path
    end
end
