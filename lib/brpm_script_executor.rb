require_relative "brpm_auto"
require 'fileutils'
require "yaml"

class BrpmScriptExecutor
  private_class_method :new

  class << self
    def execute_automation_script_in_separate_process(modul, name, params)
      BrpmAuto.setup(params)

      params_file = "#{File.expand_path(params["SS_output_dir"] || params["output_dir"] || Dir.pwd)}/params_#{params["SS_run_key"] || params["run_key"] || "000"}.yml"

      BrpmAuto.log "Creating params file #{params_file}..."
      File.open(params_file, "w") do |file|
        file.puts(params.to_yaml)
      end

      BrpmAuto.log "Executing '#{modul}' '#{name}' in a separate process..."
      Bundler.clean_system({"GEM_HOME" => ENV["BRPM_CONTENT_HOME"] || "#{ENV["BRPM_HOME"]}/modules"}, get_ruby_cmd, "-r", __FILE__, "-e", "BrpmScriptExecutor.execute_automation_script_from_other_process(\"#{modul}\", \"#{name}\", \"#{params_file}\")")
    end

    def execute_automation_script_from_other_process(modul, name, params_file)
      puts "Loading params file #{params_file}..."
      params = YAML.load_file(params_file)

      puts "Loading the BRPM Content framework..."
      BrpmAuto.setup(params)
      BrpmAuto.log "The BRPM Content framework is loaded now. (version: #{BrpmAuto.version})"

      BrpmAuto.log "Deleting params file #{params_file}..."
      FileUtils.rm(params_file)

      if params["SS_run_key"] and params["SS_script_support_path"]
        BrpmAuto.log "Loading script_support libraries..."
        require "#{params["SS_script_support_path"]}/ssh_script_header.rb"
        require "#{params["SS_script_support_path"]}/script_helper.rb"
        require "#{params["SS_script_support_path"]}/file_in_utf.rb"
      end

      execute_automation_script(modul, name, params)
    end

    def execute_automation_script(modul, name, params)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START automation #{name}"
        start_time = Time.now

        original_brpm_version = BrpmAuto.version

        BrpmAuto.log "Initializing module #{modul}#{params["module_version"] ? " #{params["module_version"]}" : ""} and its dependencies..."
        module_version = params["module_version"] || BrpmAuto.get_latest_installed_version(modul)
        module_path = initialize_module(modul, module_version)
        BrpmAuto.log "Finished loading the module."

        BrpmAuto.log "Note: running on a different version of the BRPM Content framework now: #{BrpmAuto.version} (was #{original_brpm_version})" if original_brpm_version != BrpmAuto.version

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

    def get_ruby_cmd
      @ruby ||= File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
    end

    # this method is used BEFORE BrpmAuto is activated so make sure not to use any logic from BrpmAuto in here
    def initialize_module(module_name, module_version)
      module_gem_path = BrpmAuto.get_module_gem_path(module_name, module_version)

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

        params = BrpmAuto.params

        BrpmAuto.log "Reloading brpm_auto to make sure the version that was specified by the Gemfile/Gemfile.lock of the module is active from now on..."
        require "brpm_auto"
        BrpmAuto.setup(params)
      end

      module_gem_path
    end
  end
end


