require "bundler"
require "yaml"

class BrpmAuto
  private_class_method :new

  class << self
    attr_reader :config
    attr_reader :version
    attr_reader :logger
    attr_reader :params
    attr_reader :request_params
    attr_reader :all_params
    attr_reader :integration_settings

    attr_reader :framework_root_path

    attr_reader :gems_root_path
    attr_reader :gemfile_lock

    attr_reader :modules_root_path
    attr_reader :external_modules_root_path

    def init
      @config = get_config
      @version = @config["version"]

      @framework_root_path = File.expand_path("#{File.dirname(__FILE__)}")

      @gems_root_path = get_gems_root_path

      @modules_root_path = File.expand_path("#{@framework_root_path}/..")
      @external_modules_root_path = File.expand_path("#{@modules_root_path}/../../modules")

      require_relative "lib/logging/brpm_logger"

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

    def require_module(module_name)
      BrpmAuto.log "Loading module #{module_name}..."

      internal_module_path = "#{@modules_root_path}/#{module_name}"
      external_module_path = "#{@external_modules_root_path}/#{module_name}"

      if File.exists?(internal_module_path)
        module_path = internal_module_path
        BrpmAuto.log "Found the module in framework module path #{module_path}."
      elsif File.exists?(external_module_path)
        module_path = external_module_path
        BrpmAuto.log "Found the module in external module path #{module_path}."
      else
        raise "Module #{module_name} is not installed.\nSearched in:\n - internal path: #{internal_module_path}\n - external path: #{external_module_path}"
      end

      module_config_file_path = "#{module_path}/config.yml"
      if File.exist?(module_config_file_path)
        module_config = YAML.load_file(module_config_file_path)
        if module_config["dependencies"]
          BrpmAuto.log "Loading the dependent modules..."
          module_config["dependencies"].each do |dependency|
            require_module(dependency)
          end
        end
      else
        BrpmAuto.log "No config file found."
      end

      BrpmAuto.log "Loading the libraries of module #{module_name}..."
      require_libs(module_path)

      module_path
    end

    def require_module_from_gem(module_name, module_version = nil)
      module_version ||= get_latest_installed_version(module_name)
      module_gem_path = get_module_gem_path(module_name, module_version)

      if File.exists?(module_gem_path)
        BrpmAuto.log "Found the module in gem path #{module_gem_path}."
      else
        raise Gem::GemNotFoundException, "Module #{module_name} version #{module_version} is not installed. Expected it on path #{module_gem_path}."
      end

      gemfile_lock_path = "#{module_gem_path}/Gemfile.lock"
      if File.exists?(gemfile_lock_path)
        BrpmAuto.log "Found a Gemfile.lock: #{gemfile_lock_path}. Parsing the version numbers for later usage..."
        @gemfile_lock = Bundler::LockfileParser.new(Bundler.read_file(gemfile_lock_path))
      end

      require_module_internal(module_name, module_version)
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

    private

    def require_module_internal(module_name, module_version)
      module_path = get_module_gem_path(module_name, module_version)

      module_config_file_path = "#{module_path}/config.yml"

      if File.exist?(module_config_file_path)
        module_config = YAML.load_file(module_config_file_path)

        if module_config["dependencies"]
          BrpmAuto.log "Loading the dependent modules..."
          module_config["dependencies"].each do |dependency|
            if dependency.is_a?(Hash)
              dep_module_name = dependency.keys[0]
              if @gemfile_lock
                dep_module_version = get_version_from_gemfile_lock(dep_module_name)
              else
                dep_module_version = dependency.values[0]["version"]
              end
            else
              dep_module_name = dependency

              if ["brpm", "bladelogic", "jira"].include?(dep_module_name)
                require_module(dep_module_name)
                next
              end

              if @gemfile_lock
                dep_module_version = get_version_from_gemfile_lock(dep_module_name)
              else
                dep_module_version = get_latest_installed_version(dep_module_name)
              end
            end

            BrpmAuto.log "Loading module #{dep_module_name} version #{dep_module_version}..."
            require_module_internal(dep_module_name, dep_module_version)
          end
        end
      else
        BrpmAuto.log "No config file found."
      end

      BrpmAuto.log "Loading the libraries of module #{module_name}..."
      require_libs(module_path)

      module_path
    end

    def get_config
      YAML.load_file(File.expand_path("#{File.dirname(__FILE__)}/config.yml"))
    end

    def get_gems_root_path
      if ENV["BRPM_CONTENT_HOME"]
        ENV["BRPM_CONTENT_HOME"] # gemset location is overridden
      elsif ENV["BRPM_HOME"]
        "#{ENV["BRPM_HOME"]}/modules" # default gemset location when BRPM is installed
      elsif ENV["GEM_HOME"]
        ENV["GEM_HOME"] # default gemset location when BRPM is not installed
      else
        raise "Unable to find out the gems root path."
      end
    end

    def get_module_gem_path(module_name, module_version)
      "#{@gems_root_path}/gems/#{module_name}-#{module_version}"
    end

    def get_latest_installed_version(module_name)
      latest_version_path = get_module_gem_path(module_name, "latest")
      return "latest" if File.exists?(latest_version_path)

      all_version_search = get_module_gem_path(module_name, "*")
      version_paths = Dir.glob(all_version_search)

      raise GemNoVersionsInstalledError, "Could not find any installed version of module #{module_name}. Expected them in #{get_module_gem_path(module_name, "*")}" if version_paths.empty?

      versions = version_paths.map { |path| File.basename(path).sub("#{module_name}-", "") }

      versions.sort{ |a, b| Gem::Version.new(a) <=> Gem::Version.new(b) }.last
    end

    def get_version_from_gemfile_lock(module_name)
      spec = @gemfile_lock.specs.find { |spec| spec.name == module_name }
      spec.version
    end
  end

  self.init
end

class GemNoVersionsInstalledError < Gem::GemNotFoundException
end

class GemNotInstalledError < Gem::GemNotFoundException
end
