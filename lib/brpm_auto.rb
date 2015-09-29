require "yaml"

print "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}|Loading all files from #{File.dirname(__FILE__)}...\n"
require_relative "logging/brpm_logger"
require_relative "logging/simple_logger"

require_relative "params/params"
require_relative "params/request_params"
require_relative "params/all_params"
require_relative "params/integration_settings"

require_relative "utilities"
require_relative "rest_api"
require_relative "semaphore"

class BrpmAuto
  private_class_method :new

  class << self
    attr_reader :config
    attr_reader :version
    attr_reader :brpm_version
    attr_reader :logger
    attr_reader :params
    attr_reader :request_params
    attr_reader :all_params
    attr_reader :integration_settings

    attr_reader :framework_root_path

    def init
      @framework_root_path = File.expand_path("#{File.dirname(__FILE__)}/..")

      self.extend Utilities

      @config = get_config
      @version = @config["version"]

      @brpm_version = get_brpm_version if self.brpm_installed?
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

      @params
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

    def run_from_brpm
      @params.run_from_brpm
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

    def brpm_installed?
      ENV["BRPM_HOME"] and ! ENV["BRPM_HOME"].empty?
    end

    def require_module(module_name)
      module_spec = Gem::Specification.find_by_name(module_name) # will raise an error when the module is not installed
      module_path = module_spec.gem_dir

      module_config_file_path = "#{module_path}/config.yml"

      if File.exist?(module_config_file_path)
        module_config = YAML.load_file(module_config_file_path)

        if module_config["dependencies"]
          BrpmAuto.log "Loading the dependent modules..."
          module_config["dependencies"].each do |dependency|
            if dependency.is_a?(Hash)
              dep_module_name = dependency.keys[0]
            else
              dep_module_name = dependency
            end

            BrpmAuto.log "Loading module #{dep_module_name}..."
            require_module(dep_module_name)
          end
        end
      else
        BrpmAuto.log "No config file found."
      end

      BrpmAuto.log "Loading the libraries of module #{module_name}..."
      require_libs(module_path)

      module_path
    end

    private

    def require_libs_no_file_logging(module_path)
      require_libs(module_path, false)
    end

    def require_libs(module_path, log = true)
      lib_path = "#{module_path}/lib/**/*.rb"

      log_message = "Loading all files from #{lib_path}..."
      log ? (BrpmAuto.log log_message) : (print "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}|#{log_message}\n")

      require_files(Dir[lib_path], log)
    end

    def require_files(files, log = true)
      failed_files = []
      error_messages = []
      files.each do |file|
        if File.file?(file)
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

    def get_config
      YAML.load_file("#{@framework_root_path}/config.yml")
    end

    def get_brpm_version
      unless self.brpm_installed?
        raise "BRPM is not installed."
      end

      knob_file = "#{ENV["BRPM_HOME"]}/server/jboss/standalone/deployments/RPM-knob.yml"
      unless File.exists?(knob_file)
        raise "Could not find the knob file at the expected location (#{knob_file})"
      end

      knob = YAML.load_file(knob_file)
      version_content = File.read("#{knob["application"]["root"]}/VERSION")
      version_content.scan(/VERSION=([0-9\.]*)/)[0][0]
    end
  end

  self.init
end
