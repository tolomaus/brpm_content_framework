require "bundler"
require "yaml"

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

    attr_reader :gems_root_path
    attr_reader :gemfile_lock

    def init
      @framework_root_path = File.expand_path("#{File.dirname(__FILE__)}/..")

      require "logging/brpm_logger"

      require_libs_no_file_logging @framework_root_path

      self.extend Utilities

      @config = get_config
      @version = @config["version"]

      @brpm_version = get_brpm_version if ENV["BRPM_HOME"]

      @gems_root_path = get_gems_root_path
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

    def require_module(module_name, module_version = nil)
      module_version ||= get_latest_installed_version(module_name)
      module_gem_path = get_module_gem_path(module_name, module_version)

      if File.exists?(module_gem_path)
        BrpmAuto.log "Found module #{module_name} #{module_version || ""} in gem path #{module_gem_path}."
      else
        raise Gem::GemNotFoundException, "Module #{module_name} version #{module_version} is not installed. Expected it on path #{module_gem_path}."
      end

      gemfile_lock_path = "#{module_gem_path}/Gemfile.lock"
      if File.exists?(gemfile_lock_path) # TODO: decide how to react when multiple gems are 'required', each with a gemfile.lock
        BrpmAuto.log "Found a Gemfile.lock: #{gemfile_lock_path} so parsing the specified version numbers for later usage..."
        Dir.chdir(File.dirname(gemfile_lock_path)) do
          @gemfile_lock = Bundler::LockfileParser.new(Bundler.read_file(gemfile_lock_path))
        end
      end

      require_module_internal(module_name, module_version)
    end

    def require_libs_no_file_logging(module_path)
      require_libs(module_path, false)
    end

    def require_libs(module_path, log = true)
      lib_path = "#{module_path}/lib/**/*.rb"

      log_message = "Loading all files from #{lib_path}..."
      log ? (BrpmAuto.log log_message) : (print "#{log_message}\n")

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

    def  get_gems_root_path
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

    ###############################################################################################################################
    # Assure backward compatibility with the ssh_script_header methods when running the automation scripts in a separate process
    def set_property_flag(prop, value = nil)
      acceptable_fields = ["name", "value", "environment", "component", "global", "private"]
      flag = "#------ Block to Set Property ---------------#\n"
      if value.nil?
        flag += set_build_flag_data("properties", prop, acceptable_fields)
      else
        flag += "$$SS_Set_property{#{prop}=>#{value}}$$"
      end
      flag += "\n#------- End Set Property ---------------#\n"
      BrpmAuto.log flag
      flag
    end

    def set_server_flag(servers)
      # servers = "server_name, env\ncserver2_name, env2"
      acceptable_fields = ["name", "environment", "group"]
      flag = "#------ Block to Set Servers ---------------#\n"
      flag += set_build_flag_data("servers", servers, acceptable_fields)
      flag += "\n#------ End Set Servers ---------------#\n"
      BrpmAuto.log flag
      flag
    end

    def set_component_flag(components)
      # comps = "comp_name, version\ncomp2_name, version2"
      flag = "#------ Block to Set Components ---------------#\n"
      acceptable_fields = ["name", "version", "environment", "application"]
      flag += set_build_flag_data("components", components, acceptable_fields)
      flag += "\n#------ End Set Components ---------------#\n"
      BrpmAuto.log flag
      flag
    end

    def set_titles_acceptable?(cur_titles, acceptable_titles)
      cur_titles.each.reject{ |cur| acceptable_titles.include?(cur)}.count == 0
    end

    def set_build_flag_data(set_item, set_data, acceptable_titles)
      flag = ""; msg = ""
      lines = set_data.split("\n")
      titles = lines[0].split(",").map{ |it| it.strip }
      if set_titles_acceptable?(titles, acceptable_titles)
        flag += "$$SS_Set_#{set_item}{\n"
        flag += "#{titles.join(", ")}\n"
        lines[1..-1].each do |line|
          if line.split(",").count == titles.count
            flag += "#{line}\n"
          else
            msg += "Skipped: #{line}"
          end
        end
        flag += "}$$\n"
      else
        flag += "ERROR - Unable to set #{set_item} - improper format\n"
      end
      flag += msg
    end

    def set_application_version(prop, value)
      # set_application_flag(app_name, version)
      flag = "#------ Block to Set Application Version ---------------#\n"
      flag += "$$SS_Set_application{#{prop}=>#{value}}$$"
      flag += "\n#------ End Set Application ---------------#\n"
      BrpmAuto.log(flag)
      flag
    end

    def pack_response(argument_name, response)
      flag = "#------ Block to Set Pack Response ---------------#\n"
      unless argument_name.nil?
        if response.is_a?(Hash)
          # Used for out-table output parameter
          flag += "$$SS_Pack_Response{#{argument_name}@@#{response.to_json}}$$"
        else
          flag += "$$SS_Pack_Response{#{argument_name}=>#{response}}$$"
        end
      end
      flag += "\n#------- End Set Pack Response Block ---------------#\n"
      BrpmAuto.log flag
      flag
    end
    ###############################################################################################################################

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
      YAML.load_file("#{@framework_root_path}/config.yml")
    end

    def get_brpm_version
      knob = YAML.load_file("#{ENV["BRPM_HOME"]}/server/jboss/standalone/deployments/RPM-knob.yml")
      version_content = File.read("#{knob["application"]["root"]}/VERSION")
      version_content.scan(/VERSION=([0-9\.]*)/)[0][0]
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
