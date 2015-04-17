class BrpmAuto
  private_class_method :new

  class << self
    attr_reader :params
    attr_reader :base_brpm_url
    attr_reader :base_brpm_api_token

    attr_reader :step_dir
    attr_reader :request_dir
    attr_reader :automation_results_dir

    attr_reader :request_id
    attr_reader :step_id
    attr_reader :step_number
    attr_reader :step_name
    attr_reader :run_key

    attr_reader :integration_server_settings

    attr_reader :debug

    attr_reader :modules_root_path

    def setup
      @modules_root_path = File.expand_path("#{File.dirname(__FILE__)}/..")
      $LOAD_PATH << @modules_root_path

      require "framework/lib/logger"

      require_libs "framework", false
    end

    def set_params(params)
      @params = params
      @base_brpm_url = params["SS_base_url"]
      @base_brpm_api_token = params["SS_api_token"]

      @step_dir = params["SS_output_dir"]
      @request_dir = File.expand_path("..", @step_dir)
      @automation_results_dir = params["SS_automation_results_dir"] || File.expand_path("../../../..", @step_dir)

      @request_id = params["request_id"]
      @step_id = params["step_id"]
      @step_number = params["step_number"]
      @step_name = params["step_name"]
      @run_key = params["SS_run_key"]


=begin

      application: 'E-Finance'
      component: 'EF - .NET web front end'
      component_version: '3.2.20'

      request_environment: 'development'
      request_id: '1953'
      request_name: 'Deploy E-Finance'
      request_number: '1953'
      request_plan: 'E-Finance Release 2015 04'
      request_plan_id: '114'
      request_plan_member_id: '427'
      request_plan_stage: 'Development'
      request_run_id: ''
      request_run_name: ''
      request_scheduled_at: ''
      request_started_at: '2015-04-14 07:39:54 -0500'
      request_status: 'started'

      server1000_name: 'EF - .NET web server - development'
      server1001_dns: ''
      server1002_ip_address: ''
      server1003_os_platform: ''
      servers: 'EF - .NET web server - development'

      step_description: ''
      step_estimate: '5'
      step_id: '7738'
      step_name: 'Deploy .NET web front end'
      step_number: '9'

      step_version: '3.2.20'
      step_version_artifact_url: ''

      ticket_ids: ''
      tickets_foreign_ids: ''
=end



      if params["SS_integration_dns"]
        @integration_server_settings = IntegrationServerSettings.new(
            params["SS_integration_dns"],
            params["SS_integration_username"],
            params["SS_integration_password"] || decrypt_string_with_prefix(params["SS_integration_password_enc"]),
            params["SS_integration_details"]
        )
      end

      @debug = params["debug"] == "true"
    end

    def require_libs(modul, log = true)
      lib_path = "#{@modules_root_path}/#{modul}/lib/**/*.rb"
      Dir[lib_path].each do |file|
        if File.file?(file)
          Logger.log "Loading #{file}..." if log
          require file
        end
      end
    end

    def require_module(modul)
      Logger.log "Loading the module's own libraries..."
      require_libs(modul)

      module_config_file_path = "#{modul}/config.yml"
      if File.exist?(module_config_file_path)
        module_config = YAML.load(module_config_file_path)
        if module_config.has_key?["dependencies"] and module_config["dependencies"].count > 0
          Logger.log "Loading the dependent modules' libraries..."
          module_config["dependencies"].each do |k, v|
            Logger.log "Loading module #{k}'s libraries..."
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

    def execute_script_from_module(modul, name, params)
      begin
        set_params(params)

        Logger.log ""
        Logger.log ">>>>>>>>>>>>>> START automation #{name}"
        start_time = Time.now

        Logger.log "Loading the dependencies..."
        require_module(modul)

        automation_script_path = "#{modul}/automations/#{name}.rb"

        Logger.log "Loading #{automation_script_path}..."
        load automation_script_path

        if defined?(execute_script)
          Logger.log "Calling execute_script(params)..."
          execute_script(params)
        end

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
        set_params(params)

        Logger.log ""
        Logger.log ">>>>>>>>>>>>>> START resource automation #{name}"
        start_time = Time.now

        Logger.log "Loading the dependencies..."
        require_module(modul)

        automation_script_path = "#{modul}/resource_automations/#{name}.rb"

        Logger.log "Loading #{automation_script_path}..."
        load automation_script_path

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
  end

  self.setup
end