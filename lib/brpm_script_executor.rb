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

      if params["SS_run_key"] and params["SS_script_support_path"]
        BrpmAuto.log "Loading script_support libraries..."
        require "#{params["SS_script_support_path"]}/ssh_script_header.rb"
        require "#{params["SS_script_support_path"]}/script_helper.rb"
        require "#{params["SS_script_support_path"]}/file_in_utf.rb"
      end

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
      module_version = params["module_version"] || BrpmAuto.get_latest_installed_version(modul)
      module_path = BrpmAuto.get_module_gem_path(modul, module_version)

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

      BrpmAuto.log "Found a Gemfile (#{gemfile_path}) so the automation script will have to run inside bundler."
      env_vars["BUNDLE_GEMFILE"] = gemfile_path
      require_statements += "require 'bundler/setup'; "
      # TODO Bundler.require

      BrpmAuto.log "Executing automation script '#{name}' from module '#{modul}' in a separate process..."
      result = Bundler.clean_system(env_vars, RbConfig.ruby, "-e", "#{require_statements}; require 'brpm_script_executor'; BrpmScriptExecutor.execute_automation_script_from_other_process(\"#{modul}\", \"#{name}\", \"#{params_file}\", \"#{automation_type}\", \"#{parent_id}\", \"#{offset}\", \"#{max_records}\")")
      if result.nil?
        BrpmAuto.log_error("The process that executed the automation script returned with 'Command execution failed'.")
      elsif result == false
        BrpmAuto.log_error("The process that executed the automation script  returned with non-zero exit code: #{$?.exitstatus}")
      end

      result
    end

    def execute_automation_script_internal(modul, name, params, automation_type, parent_id = nil, offset = nil, max_records = nil)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START #{automation_type} #{name}"
        start_time = Time.now

        case automation_type
        when "automation"
          module_version = params["module_version"] || BrpmAuto.get_latest_installed_version(modul)
        when "resource_automation"
          module_version = BrpmAuto.get_latest_installed_version(modul) #TODO: get the module version of the calling script
        else
          raise "Automation type #{automation_type} is not supported."
        end
        module_path = BrpmAuto.get_module_gem_path(modul, module_version)

        if File.exists?(module_path)
          BrpmAuto.log "Found module #{modul} #{module_version || ""} in gem path #{module_path}."
        else
          raise Gem::GemNotFoundException, "Module #{modul} version #{module_version} is not installed. Expected it on path #{module_path}."
        end

        BrpmAuto.require_module(modul, module_version)

        automation_script_path = "#{module_path}/#{automation_type}s/#{name}.rb"

        BrpmAuto.log "Executing the #{automation_type} script #{automation_script_path}..."
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

        #load "#{File.dirname(__FILE__)}/write_to.rb" if BrpmAuto.params.run_from_brpm
      end
    end
  end
end


