require "yaml"

class BrpmAuto
  private_class_method :new

  class << self
    attr_reader :logger
    attr_reader :params
    attr_reader :request_params
    attr_reader :all_params
    attr_reader :integration_settings

    attr_reader :framework_root_path
    attr_reader :modules_root_path
    attr_reader :external_modules_root_path

    def init
      @framework_root_path = File.expand_path("#{File.dirname(__FILE__)}")

      @modules_root_path = File.expand_path("#{@framework_root_path}/..")
      $LOAD_PATH << @modules_root_path

      @external_modules_root_path = File.expand_path("#{@modules_root_path}/../../modules")
      $LOAD_PATH << @external_modules_root_path if Dir.exist?(@external_modules_root_path)

      require "framework/lib/logging/brpm_logger"

      require_libs_no_file_logging "#{@modules_root_path}/framework"

      self.extend Utilities
    end

    def setup(params = {})
      @params = Params.new(params)

      load_server_params
      load_customer_include_file

      if @params.run_from_brpm
        @logger = BrpmLogger.new
        @request_params = RequestParams.new_for_request(@params.automation_results_dir, @params.application, @params.request_id)
      else
        initialize_logger(@params.log_file, @params.also_log_to_console)
        initialize_request_params(@params.output_dir)
      end

      @all_params = AllParams.new(@params, @request_params)

      if @params["SS_integration_dns"]
        @integration_settings = IntegrationSettings.new(
            @params["SS_integration_dns"],
            @params["SS_integration_username"],
            @params["SS_integration_password"],
            @params["SS_integration_details"],
            @params["SS_project_server"],
            @params["SS_project_server_id"]
        )
      elsif defined?(SS_integration_dns)
        @integration_settings = IntegrationSettings.new(
            SS_integration_dns,
            SS_integration_username,
            SS_integration_password,
            SS_integration_details,
            SS_project_server,
            SS_project_server_id
        )
      end
    end

    def require_libs_no_file_logging(module_path)
      require_libs(module_path, false)
    end

    def require_libs(module_path, log = true)
      lib_path = "#{module_path}/lib/**/*.rb"
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
      BrpmAuto.log "Loading module #{modul}..."

      if File.exists?("#{@modules_root_path}/#{modul}")
        module_path = "#{@modules_root_path}/#{modul}"
      elsif File.exists?("#{@external_modules_root_path}/#{modul}")
        module_path = "#{@external_modules_root_path}/#{modul}"
      else
        raise "Module #{modul} is not installed."
      end
      BrpmAuto.log "Found the module on #{module_path}."

      module_config_file_path = "#{module_path}/config.yml"
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
      require_libs(module_path)
    end

    def first_defined(first, second)
      if first and ! first.empty?
        return first
      else
        return second
      end
    end

    def load_server_params
      server_config_file_path = "#{self.params.config_dir}/server.yml"
      if File.exists?(server_config_file_path)
        server_config = YAML.load_file(server_config_file_path)
        server_config.each do |key, value|
          @params[key] = value unless @params.has_key?(key)
        end
      end
    end

    def load_customer_include_file
      customer_include_file_path = "#{self.params.config_dir}/customer_include.rb"
      if File.exists?(customer_include_file_path)
        load customer_include_file_path # use load instead of require to avoid having to restart BRPM after modifying the customer include file in a resource automation scenario
        if defined?(get_customer_include_params)
          customer_include_params = get_customer_include_params
          customer_include_params.each do |key, value|
            @params[key] = value
          end
        end
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

    def message_box(message, m_type = "sep")
      @logger.message_box(message, m_type)
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

