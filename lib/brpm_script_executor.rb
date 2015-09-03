require_relative "brpm_auto"
require 'fileutils'
require "yaml"

class BrpmScriptExecutor
  private_class_method :new

  class << self
    def execute_automation_script(modul, name, params)
      execute_automation_script_internal(modul, name, params, "automation")
    end

    def execute_resource_automation_script(modul, name, params, parent_id, offset, max_records)
      execute_automation_script_internal(modul, name, params, "resource_automation", parent_id, offset, max_records)
    end

    def execute_automation_script_in_separate_process(modul, name, params)
      execute_automation_script_in_separate_process_internal(modul, name, params, "automation")
    end

    def execute_resource_automation_script_in_separate_process(modul, name, params, parent_id, offset, max_records)
      execute_automation_script_in_separate_process_internal(modul, name, params, "resource_automation", parent_id, offset, max_records)
    end

    def execute_automation_script_from_other_process(modul, name, params_file, automation_type, parent_id = nil, offset = nil, max_records = nil)
      raise "Params file #{params_file} doesn't exist." unless File.exists?(params_file)

      puts "Loading params file #{params_file}..."
      params = YAML.load_file(params_file)

      puts "Loading the BRPM Content framework..."
      BrpmAuto.setup(params)
      BrpmAuto.log "The BRPM Content framework is loaded now. (version: #{BrpmAuto.version})"

      BrpmAuto.log "Deleting params file #{params_file}..."
      FileUtils.rm(params_file)

      load File.expand_path("#{File.dirname(__FILE__)}/../infrastructure/create_output_file.rb")

      execute_automation_script_internal(modul, name, params, automation_type, parent_id, offset, max_records)
    end

    private

    def execute_automation_script_in_separate_process_internal(modul, name, params, automation_type, parent_id = nil, offset = nil, max_records = nil)
      BrpmAuto.setup(params)

      params_file = "#{File.expand_path(params["SS_output_dir"] || params["output_dir"] || Dir.pwd)}/params_#{params["SS_run_key"] || params["run_key"] || "000"}.yml"

      BrpmAuto.log "Creating params file #{params_file}..."
      File.open(params_file, "w") do |file|
        file.puts(params.to_yaml)
      end

      env_vars = {}
      env_vars["GEM_HOME"] = ENV["BRPM_CONTENT_HOME"] || "#{ENV["BRPM_HOME"]}/modules"

      BrpmAuto.log "Finding the module path..."
      case automation_type
      when "automation"
        module_version = params["module_version"] || get_latest_installed_version(modul)
      when "resource_automation"
        module_version = get_latest_installed_version(modul) #TODO: get the module version of the calling script
      else
        raise "Automation type #{automation_type} is not supported."
      end
      module_path = get_module_gem_path(modul, module_version)

      if File.exists?(module_path)
        BrpmAuto.log "Found module #{modul} #{module_version || ""} in path #{module_path}."
      else
        raise Gem::GemNotFoundException, "Module #{modul} version #{module_version} is not installed. Expected it on path #{module_path}."
      end

      require_statements = ""
      gemfile_path = "#{module_path}/Gemfile"
      unless File.exists?(gemfile_path)
        BrpmAuto.log_error("This module doesn't have a Gemfile. Expected it at #{gemfile_path}.")
        return
      end

      BrpmAuto.log "Using Gemfile #{gemfile_path}."
      env_vars["BUNDLE_GEMFILE"] = gemfile_path
      require_statements += "require 'bundler/setup'; "
      # TODO Bundler.require

      BrpmAuto.log "Executing automation script '#{name}' from module '#{modul}' in a separate process..."
      result = Bundler.clean_system(env_vars, RbConfig.ruby, "-e", "#{require_statements}; require 'brpm_script_executor'; BrpmScriptExecutor.execute_automation_script_from_other_process(\"#{modul}\", \"#{name}\", \"#{params_file}\", \"#{automation_type}\", \"#{parent_id}\", \"#{offset}\", \"#{max_records}\")")
      if result.nil?
        BrpmAuto.log_error("The process that executed the automation script returned with 'Command execution failed'.")
      elsif result == false
        BrpmAuto.log_error("The process that executed the automation script returned with non-zero exit code: #{$?.exitstatus}")
      end

      result
    end

    def execute_automation_script_internal(modul, name, params, automation_type, parent_id = nil, offset = nil, max_records = nil)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START #{automation_type} #{name}"
        start_time = Time.now

        module_spec = Gem::Specification.find_by_name(modul) # will raise an error when the module is not installed
        module_path = module_spec.gem_dir

        BrpmAuto.require_module(modul)

        automation_script_path = "#{module_path}/#{automation_type}s/#{name}.rb"
        unless File.exists?(automation_script_path)
          raise "Could not find automation #{name} in module #{modul}. Expected it on path #{automation_script_path}."
        end

        BrpmAuto.log "Executing the #{automation_type} script #{name} from #{automation_script_path}..."
        load automation_script_path

        if automation_type == "resource_automation"
          BrpmAuto.log "Calling execute_resource_automation_script(params, parent_id, offset, max_records)..."
          execute_script(params, parent_id, offset, max_records)
        end
      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log "\n\t" + e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = 0
        duration = stop_time - start_time unless start_time.nil?

        BrpmAuto.log ">>>>>>>>>>>>>> STOP #{automation_type} #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        #load File.expand_path("#{File.dirname(__FILE__)}/../infrastructure/write_to.rb") if BrpmAuto.params.run_from_brpm
      end
    end
    def get_module_gem_path(module_name, module_version)
      "#{get_gems_root_path}/gems/#{module_name}-#{module_version}"
    end

    def get_latest_installed_version(module_name)
      latest_version_path = get_module_gem_path(module_name, "latest")
      return "latest" if File.exists?(latest_version_path)

      # TODO: use Gem::Specification.find_by_name(@module_name, Gem::Requirement.create(Gem::Version.new(@module_version)))
      all_version_search = get_module_gem_path(module_name, "*")
      version_paths = Dir.glob(all_version_search)

      raise Gem::GemNotFoundException, "Could not find any installed version of module #{module_name}. Expected them in #{get_module_gem_path(module_name, "*")}" if version_paths.empty?

      versions = version_paths.map { |path| File.basename(path).sub("#{module_name}-", "") }

      versions.sort{ |a, b| Gem::Version.new(a) <=> Gem::Version.new(b) }.last
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
  end
end


