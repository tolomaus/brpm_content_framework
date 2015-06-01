require "yaml"

class BrpmAuto
  private_class_method :new

  class << self
    attr_reader :logger
    attr_reader :params
    attr_reader :request_params
    attr_reader :integration_settings

    attr_reader :modules_root_path

    def init
      @modules_root_path = File.expand_path("#{File.dirname(__FILE__)}/..")
      $LOAD_PATH << @modules_root_path

      require "framework/lib/logging/logger"

      require_libs_no_file_logging "framework"
    end

    def setup(params)
      @params = Params.new(params)

      if @params.run_from_brpm
        # noinspection RubyArgCount
        @logger = Logger.new(@params.request_id, @params.automation_results_dir, @params.step_id, @params.run_key, @params.step_number, @params.step_name, @params.also_log_to_console)
        @request_params = RequestParams.new_for_request(@params.automation_results_dir, @params.application, @params.request_id)
      else
        initialize_logger(@params.log_file, @params.also_log_to_console)
        initialize_request_params(@params.output_dir)
      end

      if @params["SS_integration_dns"]
        @integration_settings = IntegrationSettings.new(
            @params["SS_integration_dns"],
            @params["SS_integration_username"],
            @params["SS_integration_password"] || decrypt_string_with_prefix(@params["SS_integration_password_enc"]),
            @params["SS_integration_details"],
            @params["SS_project_server"],
            @params["SS_project_server_id"]
        )
      end
    end

    def require_libs_no_file_logging(modul)
      require_libs(modul, false)
    end

    def require_libs(modul, log = true)
      lib_path = "#{@modules_root_path}/#{modul}/lib/**/*.rb"
      require_files(Dir[lib_path], log)
    end

    def require_files(files, log = true)
      failed_files = []
      error_messages = []
      files.each do |file|
        if File.file?(file)
          log ? (BrpmAuto.log "Loading #{file}...") : (print "Loading #{file}...\n")

          begin
            require file
          rescue NameError => ne # when we require a set of files with inter-dependencies, the order is important, therefore we will retry the failed files later
            failed_files << file
            error_messages << ne
          end
        end
      end
      if failed_files.count > 0
        if failed_files.count == files.count
          raise NameError, "Following files failed loading: #{failed_files.join(", ")}\nError messages: #{error_messages.join(", ")}"
        else
          require_files(failed_files, log)
        end
      end
    end

    def require_module(modul)
      module_config_file_path = "#{@modules_root_path}/#{modul}/config.yml"
      if File.exist?(module_config_file_path)
        module_config = YAML.load_file(module_config_file_path)
        if module_config.has_key?("dependencies") and module_config["dependencies"] and module_config["dependencies"].count > 0
          BrpmAuto.log "Loading the dependent modules..."
          module_config["dependencies"].each do |dep|
            BrpmAuto.log "Loading module #{dep}..."
            require_module(dep)
          end
        end
      end

      BrpmAuto.log "Loading the libraries of module #{modul}..."
      require_libs(modul)
    end

    def privatize(expression, sensitive_data = BrpmAuto.params.private_values)

      unless sensitive_data.nil? or sensitive_data.empty?
        sensitive_data = [sensitive_data] if sensitive_data.kind_of?(String)

        sensitive_data.each do |sensitive_string|
          expression = expression.gsub(sensitive_string, "********")
        end
      end

      expression
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
      return source_path if source_path.include?(":\\")
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
    def execute_shell(command)
      cmd_result = {"stdout" => "","stderr" => "", "pid" => "", "status" => 1}
      cmd_result["stdout"] = "Running #{command}\n"
      output_dir = File.join(@params["SS_output_dir"],"#{precision_timestamp}")
      errfile = "#{output_dir}_stderr.txt"
      command = "#{command} 2>#{errfile}#{exit_code_failure}" unless Windows
      fil = File.open(errfile, "w+")
      fil.close
      cmd_result["stdout"] += "Script Output:\n"
      begin
        cmd_result["stdout"] += `#{command}`
        status = $?
        cmd_result["pid"] = status.pid
        cmd_result["status"] = status.to_i
        fil = File.open(errfile)
        stderr = fil.read
        fil.close
        cmd_result["stderr"] = stderr if stderr.length > 2
      rescue Exception => e
        cmd_result["stderr"] = "ERROR\n#{e.message}\n#{e.backtrace}"
      end
      File.delete(errfile)
      cmd_result
    end

    #TODO: merge execute_shell with exec_command
    def exec_command(command, sensitive_data = nil)
      escaped_command = command.gsub("\\", "\\\\")

      loggable_command = privatize(escaped_command, sensitive_data)

      BrpmAuto.log loggable_command
      BrpmAuto.log `#{escaped_command}`

      exit_status = $?.exitstatus
      unless exit_status == 0
        raise "Command #{loggable_command} exited with #{exit_status}."
      end
    end

    def substitute_tokens(var_string, params = nil)
      return var_string if var_string.nil?

      searchable_params = params || @params

      prop_val = var_string.match('rpm{[^{}]*}')
      while ! prop_val.nil? do
        raise "Property #{prop_val[0][4..-2]} doesn't exist" if searchable_params[prop_val[0][4..-2]].nil?
        var_string = var_string.sub(prop_val[0],searchable_params[prop_val[0][4..-2]])
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

    def initialize_logger(log_file, also_log_to_console = false)
      @logger = SimpleLogger.new(log_file, also_log_to_console)
    end

    def log(message)
      @logger.log(message)
    end

    def log_error(message)
      @logger.log_error(message)
    end

    def initialize_request_params(path)
      @request_params = RequestParams.new(path)
    end

    def get_request_params_for_request(automation_results_dir, application, request_id)
      RequestParams.new_for_request(automation_results_dir, application, request_id)
    end

    def initialize_integration_settings(dns, username, password, details)
      @integration_settings = IntegrationSettings.new(dns, username, password, details)
    end
  end

  self.init
end

