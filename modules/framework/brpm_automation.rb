class BrpmAuto
  private_class_method :new

  class << self
    attr_reader :params

    attr_reader :application
    attr_reader :component
    attr_reader :component_version

    attr_reader :request_id
    attr_reader :request_name
    attr_reader :request_number
    attr_reader :request_environment
    attr_reader :request_scheduled_at
    attr_reader :request_started_at
    attr_reader :request_status

    attr_reader :request_plan
    attr_reader :request_plan_id
    attr_reader :request_plan_member_id
    attr_reader :request_plan_stage

    attr_reader :request_run_id
    attr_reader :request_run_name

    attr_reader :step_id
    attr_reader :step_number
    attr_reader :step_name
    attr_reader :step_description
    attr_reader :step_estimate

    attr_reader :step_version
    attr_reader :step_version_artifact_url

    attr_reader :servers

    attr_reader :ticket_ids
    attr_reader :tickets_foreign_ids

    attr_reader :step_dir
    attr_reader :request_dir
    attr_reader :automation_results_dir

    attr_reader :run_key

    attr_reader :base_brpm_url
    attr_reader :base_brpm_api_token

    attr_reader :integration_server_settings

    attr_reader :debug

    attr_reader :modules_root_path

    def init
      @modules_root_path = File.expand_path("#{File.dirname(__FILE__)}/..")
      $LOAD_PATH << @modules_root_path

      require "framework/lib/logger"

      require_libs "framework", false
    end

    def setup(params)
      @params = params

      @application = params["application"]
      @component = params["component"]
      @component_version = params["component_version"]

      @request_id = params["request_id"]
      @request_name = params["request_name"]
      @request_number = params["request_number"]
      @request_environment = params["request_environment"]
      @request_scheduled_at = params["request_scheduled_at"]
      @request_started_at = params["request_started_at"]
      @request_status = params["request_status"]

      @request_plan = params["request_plan"]
      @request_plan_id = params["request_plan_id"]
      @request_plan_member_id = params["request_plan_member_id"]
      @request_plan_stage = params["request_plan_stage"]

      @request_run_id = params["request_run_id"]
      @request_run_name = params["request_run_name"]

      @step_id = params["step_id"]
      @step_number = params["step_number"]
      @step_name = params["step_name"]
      @step_description = params["step_description"]
      @step_estimate = params["step_estimate"]

      @step_version = params["step_version"]
      @step_version_artifact_url = params["step_version_artifact_url"]

      @integration_server_settings = get_server_list

      @ticket_ids = params["ticket_ids"]
      @tickets_foreign_ids = params["tickets_foreign_ids"]

      @step_dir = params["SS_output_dir"]
      @request_dir = File.expand_path("..", @step_dir)
      @automation_results_dir = params["SS_automation_results_dir"] || File.expand_path("../../../..", @step_dir)

      @run_key = params["SS_run_key"]

      @base_brpm_url = params["SS_base_url"]
      @base_brpm_api_token = params["SS_api_token"]

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

        write_to(File.read(Logger.get_step_run_log_file_path)) if defined? write_to
      end
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

        write_to(File.read(Logger.get_step_run_log_file_path)) if defined? write_to
      end
    end

    def require_libs(modul, log = true)
      lib_path = "#{@modules_root_path}/#{modul}/lib/**/*.rb"
      Dir[lib_path].each do |file|
        if File.file?(file)
          BrpmAuto.log "Loading #{file}..." if log
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

    def get_server_list(params = nil)
      params ||= @params

      rxp = /server\d+_/
      slist = {}
      lastcur = -1
      curname = ""
      params.sort.reject{ |k| k[0].scan(rxp).empty? }.each_with_index do |server, idx|
        cur = (server[0].scan(rxp)[0].gsub("server","").to_i * 0.001).round * 1000
        if cur == lastcur
          prop = server[0].gsub(rxp, "")
          slist[curname][prop] = server[1]
        else # new server
          lastcur = cur
          curname = server[1].chomp("0")
          slist[curname] = {}
        end
      end
      return slist
    end
  end

  def setup_logger(log_file)
    Logger.setup(log_file)
  end

  def log(message)
    BrpmAuto.log(message)
  end

  self.init
end

