require "yaml"

class BrpmScriptExecutor
  private_class_method :new

  class << self
    def execute_automation_script_in_separate_process(modul, name, params)
      params_file = "#{File.expand_path(params["SS_output_dir"])}/params_#{params["run_key"]}.yml"

      BrpmAuto.log "Creating params file #{params_file}..."
      File.open(params_file, "w") do |file|
        file.puts(params.to_yaml)
      end

      BrpmAuto.log "Executing '#{modul}' '#{name}'..."
      Bundler.clean_system(get_ruby_cmd, "-r", __FILE__, "-e", "BrpmScriptExecutor.execute_automation_script_same_process_from_other_process(\"#{modul}\", \"#{name}\", \"#{params_file}\")")
    end

    def execute_automation_script_from_other_process(modul, name, params_file)
      params = YAML.load(params_file)

      if params["SS_run_key"] and params["SS_script_support_path"]
        require "#{params["SS_script_support_path"]}/ssh_script_header.rb"
        require "#{params["SS_script_support_path"]}/script_helper.rb"
        require "#{params["SS_script_support_path"]}/file_in_utf.rb"
      end

      execute_automation_script(modul, name, params)
    end

    def execute_automation_script(modul, name, params)
      begin
        puts "Initializing module #{modul}#{params["module_version"] ? " #{params["module_version"]}" : ""} and its dependencies..."
        module_version = params["module_version"] || get_latest_installed_version(modul)
        module_path = initialize_module(modul, module_version)
        puts "Finished loading the module."

        require "brpm_auto"
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START automation #{name}"
        start_time = Time.now

        BrpmAuto.require_module(modul, module_version)

        automation_script_path = "#{module_path}/automations/#{name}.rb"

        BrpmAuto.log "Loading the automation script #{automation_script_path}..."
        load automation_script_path

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log "\n\t" + e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = 0
        duration = stop_time - start_time unless start_time.nil?

        BrpmAuto.log ">>>>>>>>>>>>>> STOP automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        #load "#{File.dirname(__FILE__)}/write_to.rb" if BrpmAuto.params.run_from_brpm
      end
    end

    alias_method :execute_automation_script_from_gem, :execute_automation_script

    def execute_resource_automation_script(modul, name, params, parent_id, offset, max_records)
      begin
        require "brpm_auto"

        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START resource automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading module #{modul} and its dependencies..."
        module_path = BrpmAuto.require_module(modul) #TODO: get the module version of the calling script
        BrpmAuto.log "Finished loading the module."

        automation_script_path = "#{module_path}/resource_automations/#{name}.rb"

        BrpmAuto.log "Loading the resource automation script #{automation_script_path}..."
        load automation_script_path

        BrpmAuto.log "Calling execute_resource_automation_script(params, parent_id, offset, max_records)..."
        execute_script(params, parent_id, offset, max_records)

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log "\n\t" + e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = stop_time - start_time

        BrpmAuto.log ">>>>>>>>>>>>>> STOP resource automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        #load "#{File.dirname(__FILE__)}/write_to.rb" if BrpmAuto.params.run_from_brpm
      end
    end

    alias_method :execute_resource_automation_script_from_gem, :execute_resource_automation_script

    def initialize_module(module_name, module_version)
      module_gem_path = get_module_gem_path(module_name, module_version)

      if File.exists?(module_gem_path)
        BrpmAuto.log "Found module #{module_name} #{module_version || ""} in gem path #{module_gem_path}."
      else
        raise Gem::GemNotFoundException, "Module #{module_name} version #{module_version} is not installed. Expected it on path #{module_gem_path}."
      end

      gemfile_path = "#{module_gem_path}/Gemfile"
      if File.exists?(gemfile_path)
        BrpmAuto.log "Found a Gemfile (#{gemfile_path}) so activating bundler..."
        ENV["BUNDLE_GEMFILE"] = gemfile_path
        require "bundler/setup"
        # TODO Bundler.require
      end

      module_gem_path
    end

    def get_ruby_cmd
      @ruby ||= File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])
    end

    def get_module_gem_path(module_name, module_version)
      "#{ENV["GEM_HOME"]}/gems/#{module_name}-#{module_version}"
    end

    def get_latest_installed_version(module_name)
      latest_version_path = get_module_gem_path(module_name, "latest")
      return "latest" if File.exists?(latest_version_path)

      # TODO: use Gem::Specification.find_by_name(@module_name, Gem::Requirement.create(Gem::Version.new(@module_version)))
      all_version_search = get_module_gem_path(module_name, "*")
      version_paths = Dir.glob(all_version_search)

      raise GemNoVersionsInstalledError, "Could not find any installed version of module #{module_name}. Expected them in #{get_module_gem_path(module_name, "*")}" if version_paths.empty?

      versions = version_paths.map { |path| File.basename(path).sub("#{module_name}-", "") }

      versions.sort{ |a, b| Gem::Version.new(a) <=> Gem::Version.new(b) }.last
    end
  end
end

