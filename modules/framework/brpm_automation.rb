class BrpmAuto
  private_class_method :new

  class << self
    attr_reader :logger
    attr_reader :params
    attr_reader :output_params
    attr_reader :request_params
    attr_reader :integration_settings

    attr_reader :modules_root_path

    def init
      @modules_root_path = File.expand_path("#{File.dirname(__FILE__)}/..")
      $LOAD_PATH << @modules_root_path

      require "framework/lib/logger"

      require_libs "framework", false
    end

    def execute_script_from_module(modul, name, params)
      begin
        setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading the dependencies..."
        require_module(modul)

        automation_script_path = "#{modul}/automations/#{name}.rb"

        BrpmAuto.log "Loading #{automation_script_path}..."
        load automation_script_path

        if defined?(execute_script)
          BrpmAuto.log "Calling execute_script(params)..."
          execute_script(params)
        end

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = 0
        duration = stop_time - start_time unless start_time.nil?

        BrpmAuto.log ">>>>>>>>>>>>>> STOP automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        write_to(File.read(@logger.get_step_run_log_file_path)) if defined? write_to
      end

      @output_params
    end

    def execute_resource_automation_script_from_module(modul, name, params, parent_id, offset, max_records)
      begin
        setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START resource automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading the dependencies..."
        require_module(modul)

        automation_script_path = "#{modul}/resource_automations/#{name}.rb"

        BrpmAuto.log "Loading #{automation_script_path}..."
        load automation_script_path

        BrpmAuto.log "Calling execute_resource_automation_script(params, parent_id, offset, max_records)..."
        execute_resource_automation_script(params, parent_id, offset, max_records)

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = stop_time - start_time

        BrpmAuto.log ">>>>>>>>>>>>>> STOP resource automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        write_to(File.read(@logger.get_step_run_log_file_path)) if defined? write_to
      end

      @output_params
    end

    def require_libs(modul, log = true)
      lib_path = "#{@modules_root_path}/#{modul}/lib/**/*.rb"
      Dir[lib_path].each do |file|
        if File.file?(file)
          if log
            BrpmAuto.log "Loading #{file}..."
          else
            print "Loading #{file}...\n"
          end

          require file
        end
      end
    end

    def require_module(modul)
      BrpmAuto.log "Loading the module's own libraries..."
      require_libs(modul)

      module_config_file_path = "#{modul}/config.yml"
      if File.exist?(module_config_file_path)
        module_config = YAML.load(module_config_file_path)
        if module_config.has_key?["dependencies"] and module_config["dependencies"].count > 0
          BrpmAuto.log "Loading the dependent modules' libraries..."
          module_config["dependencies"].each do |k, v|
            BrpmAuto.log "Loading module #{k}'s libraries..."
            require_libs(k)
          end
        end
      end
    end

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

    def initialize_logger(log_file, debug = false)
      @logger = SimpleLogger.new(log_file, debug)
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

    private

      def setup(params)
        @params = Params.new(params)
        @output_params = {}

        if params["run_key"]
          @logger = Logger.new(@params.request_id, @params.automation_results_dir, @params.step_id, @params.run_key, @params.step_number, @params.step_name, @params.debug)
        end

        if @params.automation_results_dir
          @request_params = RequestParams.new_for_request(@params.automation_results_dir, @params.application, @params.request_id)
        end

        if @params["SS_integration_dns"]
          @integration_settings = IntegrationSettings.new(
              @params["SS_integration_dns"],
              @params["SS_integration_username"],
              @params["SS_integration_password"] || decrypt_string_with_prefix(@params["SS_integration_password_enc"]),
              @params["SS_integration_details"]
          )

        end

      end
  end

  self.init
end

