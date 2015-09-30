require_relative "brpm_auto"
require 'fileutils'
require "yaml"

class BrpmScriptExecutor
  private_class_method :new

  class << self
    def execute_automation_script_in_separate_process(modul, name, params)
      execute_automation_script_in_separate_process_internal(modul, name, params, "automation")
    end

    def execute_resource_automation_script_in_separate_process(modul, name, params, parent_id, offset, max_records)
      execute_automation_script_in_separate_process_internal(modul, name, params, "resource_automation", parent_id, offset, max_records)
    end

    def execute_automation_script_in_separate_process_internal(modul, name, params, automation_type, parent_id = nil, offset = nil, max_records = nil)
      BrpmAuto.setup(params)
      BrpmAuto.log ""
      BrpmAuto.log "Executing #{automation_type} '#{name}' from module '#{modul}' in a separate process..."

      BrpmAuto.log "Finding the module's version..."
      case automation_type
      when "automation"
        module_version = params["module_version"] || get_latest_installed_version(modul)
      when "resource_automation"
        module_version = get_latest_installed_version(modul) #TODO: get the module version of the calling script
      else
        raise "Automation type #{automation_type} is not supported."
      end

      case BrpmAuto.params["execute_automation_scripts_in_docker"]
      when "always"
        use_docker = true
      when "if_docker_image_exists"
        BrpmAuto.log "Checking if a docker image exists for bmcrlm/#{modul}:#{module_version}..."
        output = `docker history -q bmcrlm/#{modul}:#{module_version} 2>&1 >/dev/null`
        if output.empty?
          use_docker = true
        else
          BrpmAuto.log "The image doesn't exist locally, checking if we can pull it from the Docker Hub..."
          output = `docker pull bmcrlm/#{modul}:#{module_version}`
          use_docker = (output =~ /Image is up to date for/)
        end
      else
        use_docker = false
      end
      BrpmAuto.log "The automation script will be executed in a docker container." if	use_docker

      working_path = File.expand_path(BrpmAuto.params.output_dir)
      params_file = "params_#{params["SS_run_key"] || params["run_key"] || "000"}.yml"
      params_path = "#{working_path}/#{params_file}"
      automation_results_path = params["SS_automation_results_dir"] || working_path

      if use_docker
        params["SS_output_dir"] = "/workdir"
        params["SS_output_file"].sub!(working_path, "/workdir") if params["SS_output_file"]
        params["SS_automation_results_dir"] = "/automation_results"

        params["log_file"].sub!(working_path, "/workdir") if params["log_file"]
      end

      BrpmAuto.log "Temporarily storing the params to #{params_path}..."
      File.open(params_path, "w") do |file|
        file.puts(params.to_yaml)
      end

      if use_docker
        BrpmAuto.log "Executing the script in a docker container..."
        command = "docker run -v #{working_path}:/workdir -v #{automation_results_path}:/automation_results --rm bmcrlm/#{modul}:#{module_version} /docker_execute_automation \"#{name}\" \"/workdir/#{params_file}\" \"#{automation_type}\""
        if automation_type == "resource_automation"
          command += " \"#{parent_id}\"" if parent_id
          command += " \"#{offset}\"" if offset
          command += " \"#{max_records}\"" if max_records
        end
        BrpmAuto.log command
        return_value = system(command)
      else
        env_vars = {}
        env_vars["GEM_HOME"] = ENV["BRPM_CONTENT_HOME"] || "#{ENV["BRPM_HOME"]}/modules"

        module_path = get_module_gem_path(modul, module_version)

        if File.exists?(module_path)
          BrpmAuto.log "Found module #{modul} #{module_version || ""} in path #{module_path}."
        else
          raise Gem::GemNotFoundException, "Module #{modul} version #{module_version} is not installed. Expected it on path #{module_path}."
        end

        gemfile_path = "#{module_path}/Gemfile"
        if File.exists?(gemfile_path)
          BrpmAuto.log "Using Gemfile #{gemfile_path}."
          env_vars["BUNDLE_GEMFILE"] = gemfile_path
          require_bundler = "require 'bundler/setup';"
        else
          BrpmAuto.log("This module doesn't have a Gemfile.")
          require_bundler = ""
        end

        BrpmAuto.log "Executing the script in a separate process..."
        return_value = Bundler.clean_system(env_vars, "ruby", "-e", "#{require_bundler}require 'brpm_script_executor'; BrpmScriptExecutor.execute_automation_script_from_other_process(\"#{modul}\", \"#{name}\", \"#{params_path}\", \"#{automation_type}\", \"#{parent_id}\", \"#{offset}\", \"#{max_records}\")")
      end

      FileUtils.rm(params_path) if File.exists?(params_path)
      if return_value.nil?
        message = "The process that executed the automation script returned with 'Command execution failed'."
        BrpmAuto.log_error message
        raise message
      elsif return_value == false
        message = "The process that executed the automation script returned with non-zero exit code: #{$?.exitstatus}"
        BrpmAuto.log_error message
        raise message
      end

      if automation_type == "resource_automation"
        result_file = params_file.sub!("params", "result")
        BrpmAuto.log "Loading the result from #{result_file} and cleaning it up..."
        result = YAML.load_file(result_file)
        FileUtils.rm result_file

        result
      else
        return_value
      end
    end

    def execute_automation_script_from_other_process(modul, name, params_file, automation_type, parent_id = nil, offset = nil, max_records = nil)
      raise "Params file #{params_file} doesn't exist." unless File.exists?(params_file)

      puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}|  Loading the params from #{params_file} and cleaning it up..."
      params = YAML.load_file(params_file)
      FileUtils.rm(params_file)

      puts "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}|  Setting up the BRPM Content framework..."
      BrpmAuto.setup(params)
      BrpmAuto.log "  BRPM Content framework is version #{BrpmAuto.version}."

      if BrpmAuto.params["SS_run_key"] and BrpmAuto.params["SS_script_support_path"]
        BrpmAuto.log "  Loading the BRPM core framework's libraries..."
        load File.expand_path("#{File.dirname(__FILE__)}/../infrastructure/create_output_file.rb")
      end

      result = execute_automation_script_internal(modul, name, params, automation_type, parent_id, offset, max_records)
      if automation_type == "resource_automation"
        result_file = params_file.sub!("params", "result")
        BrpmAuto.log "  Temporarily storing the result to #{result_file}..."
        FileUtils.rm(result_file) if File.exists?(result_file)
        File.open(result_file, "w") do |file|
          file.puts(result.to_yaml)
        end
      end
    end

    def execute_automation_script(modul, name, params)
      execute_automation_script_internal(modul, name, params, "automation")
    end

    def execute_resource_automation_script(modul, name, params, parent_id, offset, max_records)
      execute_automation_script_internal(modul, name, params, "resource_automation", parent_id, offset, max_records)
    end

    def execute_automation_script_internal(modul, name, params, automation_type, parent_id = nil, offset = nil, max_records = nil)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START #{automation_type} #{modul} #{name}"
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

        BrpmAuto.log ">>>>>>>>>>>>>> STOP #{automation_type} #{modul} #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        #load File.expand_path("#{File.dirname(__FILE__)}/../infrastructure/write_to.rb") if BrpmAuto.params.run_from_brpm
      end
    end

    ############################################################################################################################################################
    # These methods are used to find gems outside of the active bundle so they should not rely on any logic from the gem or bundler libraries
    def get_module_gem_path(module_name, module_version)
      "#{get_gems_root_path}/gems/#{module_name}-#{module_version}"
    end

    def get_latest_installed_version(module_name)
      latest_version_path = get_module_gem_path(module_name, "latest")
      return "latest" if File.exists?(latest_version_path)

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
    ############################################################################################################################################################

  end
end


