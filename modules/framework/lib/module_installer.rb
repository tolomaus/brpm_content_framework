class ModuleInstaller
  def install_module(module_name, module_version)
    BrpmAuto.log "Installing module #{module_name} #{module_version.nil? ? "" : module_version}..."

    specs = install_gem(module_name, module_version)
    module_spec = specs.last

    install_bundle_if_necessary(module_spec)

    if brpm_installed_locally?
      BrpmAuto.log "A BRPM instance is installed locally"

      brpm_content_spec = specs.find { |spec| spec.name == "brpm_content" }
      if brpm_content_spec and brpm_content_spec.version > Gem::Version.new(BrpmAuto.version)
        BrpmAuto.log "WARNING - A newer version of brpm_content was installed."

        BrpmAuto.log "Checking if the symlink to brpm_content-latest should be updated..."
        update_symlink_to_brpm_content_if_necessary(brpm_content_spec)

        BrpmAuto.log "Copying the log.html file to te automation_results directory..."
        FileUtils.cp("#{brpm_content_spec.gem_dir}/modules/framework/log.html", "#{ENV["BRPM_HOME"]}/automation_results")
      end

      BrpmAuto.log "Preparing the connectivity to BRPM..."
      if prepare_brpm_connection
        module_friendly_name = get_module_friendly_name(module_name)
        BrpmAuto.log "Creating an automation category for #{module_friendly_name} if one doesn't exist yet..."
        create_automation_category_if_not_exists(module_friendly_name)

        BrpmAuto.log "Installing the automation script wrappers in the local BRPM instance..."
        install_auto_script_wrappers(module_spec.gem_dir, module_spec.name)
      end
    end
  end

  def prepare_brpm_connection
    brpm_file = File.expand_path("~/.brpm")

    config = nil
    if File.exists?(brpm_file)
      config = YAML.load_file(brpm_file)
    end

    if config
      unless config["brpm_url"] and config["brpm_api_token"]
        BrpmAuto.log "WARNING - Properties brpm_url and/or brpm_api_token don't exist in file ~/.brpm so not installing the automation script wrappers in BRPM. If you want to install them the next time you should add brpm_url and brpm_api_token properties in yaml format in file ~/.brpm."
        return false
      end
    else
      BrpmAuto.log "WARNING - File ~/.brpm doesn't exist so not installing the automation script wrappers in BRPM. If you want to install them the next time you should create this file and add brpm_url and brpm_api_token properties in yaml format."
      return false
    end

    begin
      BrpmAuto.require_module_from_gem "brpm_module_brpm"
    rescue Gem::GemNotFoundException
      BrpmAuto.log "WARNING - Module brpm_module_brpm is not installed so not installing the automation script wrappers in BRPM."
      return false
    end

    @brpm_rest_client = BrpmRestClient.new(config["brpm_url"], config["brpm_api_token"])
    true
  end

  def install_gem(module_name, module_version)
    if BrpmAuto.run_from_brpm or BrpmAuto.params.unit_test
      # we need to override the GEM_HOME env var, otherwise the gems will be installed in BRPM's own gemset
      ENV["GEM_HOME"] = ENV["BRPM_CONTENT_HOME"] || "#{ENV["BRPM_HOME"]}/modules"
      Gem.paths = ENV
    end

    if module_version
      BrpmAuto.log "Executing command 'gem install #{module_name} -v #{module_version}'..."
      specs = Gem.install(module_name, module_version)
    else
      BrpmAuto.log "Executing command 'gem install #{module_name}'..."
      specs = Gem.install(module_name)
    end
    BrpmAuto.log "Installed gems:"
    specs.each do |spec|
      BrpmAuto.log "  - #{spec.name} #{spec.version}"
    end
    specs
  end

  def install_bundle_if_necessary(spec)
    gemfile = File.join(spec.gem_dir, "Gemfile")
    gemfile_lock = File.join(spec.gem_dir, "Gemfile.lock")

    if File.exists?(gemfile) && File.exists?(gemfile_lock)
      BrpmAuto.log "Found a Gemfile.lock so executing command 'bundle install --gemfile #{gemfile}'..."
      # %x(bundle install --gemfile #{gemfile})
      result = BrpmAuto.execute_shell("bundle install --gemfile #{gemfile}") #TODO: check if we must set GEM_HOME (when run from BRPM)
      BrpmAuto.log result["stdout"] if result["stdout"] and !result["stdout"].empty?
      unless result["status"] == 0
        raise result["stderr"]
      end
    end
  end

  def update_symlink_to_brpm_content_if_necessary(brpm_content_spec)
    new_version_path = brpm_content_spec.gem_dir
    symlink_path = "#{ENV["GEM_HOME"]}/gems/brpm_content-latest"

    BrpmAuto.log "A newer version of brpm_content was installed so updating symlink #{symlink_path} to #{new_version_path}..."
    result = BrpmAuto.execute_shell("ln -sfn #{new_version_path} #{symlink_path}")
    BrpmAuto.log result["stdout"] if result["stdout"] and !result["stdout"].empty?
    unless result["status"] == 0
      raise result["stderr"]
    end
  end

  def brpm_installed_locally?
    ENV["BRPM_HOME"] and !ENV["BRPM_HOME"].empty?
  end

  def get_module_friendly_name(module_name)
    "#{module_name.sub("brpm_module_", "").capitalize}"
  end

  def create_automation_category_if_not_exists(module_friendly_name)
    list_item = @brpm_rest_client.get_list_item_by_name(module_friendly_name)

    unless list_item
      BrpmAuto.log "Automation category #{module_friendly_name} doesn't exist yet, so creating it now..."
      list_item = {}
      list_item["list_id"] = 24 # AutomationCategory TODO: find the id by the name of the list
      list_item["value_text"] = module_friendly_name
      @brpm_rest_client.create_list_item_by_hash(list_item)
    end
  end

  def install_auto_script_wrappers(module_path, module_name)
    BrpmAuto.log "Retrieving the integration servers..."
    integration_servers = @brpm_rest_client.get_project_servers

    # For resource automations
    resource_automation_dir = "#{module_path}/resource_automations"
    resource_automation_script_paths = Dir.glob("#{resource_automation_dir}/*.rb")

    failed_scripts = []
    if resource_automation_script_paths.size > 0
      BrpmAuto.log "Installing the wrapper scripts for the resource automations..."

      resource_automation_script_paths.each do |auto_script_path|
        begin
          install_auto_script_wrapper(auto_script_path, "ResourceAutomation", module_name, integration_servers)
        rescue Exception => e
          failed_scripts << auto_script_path
          BrpmAuto.log_error(e)
          BrpmAuto.log e.backtrace.join("\n\t")
        end
      end
    end

    # For automations
    automation_dir = "#{module_path}/automations"
    automation_script_paths = Dir.glob("#{automation_dir}/*.rb")

    if automation_script_paths.size > 0
      BrpmAuto.log "Installing the wrapper scripts for the automations..."

      automation_script_paths.each do |auto_script_path|
        begin
          install_auto_script_wrapper(auto_script_path, "Automation", module_name, integration_servers)
        rescue Exception => e
          failed_scripts << auto_script_path
          BrpmAuto.log_error(e)
          BrpmAuto.log e.backtrace.join("\n\t")
        end
      end
    end

    if failed_scripts.size > 0
      BrpmAuto.log "The following wrapper scripts generated errors during the installation:"
      failed_scripts.each do |failed_script|
        BrpmAuto.log "  - #{failed_script}"
      end
    else
      BrpmAuto.log "All wrapper scripts were installed successfully."
    end
  end

  def install_auto_script_wrapper(auto_script_path, automation_type, module_name, integration_servers)
    auto_script_name = File.basename(auto_script_path, ".rb")
    BrpmAuto.log "Installing the wrapper script for resource automation #{auto_script_name}..."

    auto_script_config_path = "#{File.dirname(auto_script_path)}/#{auto_script_name}.txt"

    auto_script_config_content = File.exists?(auto_script_config_path) ? File.read(auto_script_config_path) : ""
    match = auto_script_config_content.match(/###\n(.*)\n###/m)
    input_params_content = match ? "#{match[1]}\n" : ""

    if automation_type == "Automation"
      matches = input_params_content.scan(/^# {0,1}(.*)/) || []
      input_params_yaml = YAML.load(matches.join("\n")) || {}

      input_params_content += get_input_params_template(input_params_yaml)
    end

    wrapper_script_content = ""
    unless input_params_content.empty?
      wrapper_script_content = "###\n#{input_params_content}###\n"
    end

    auto_script_config = YAML.load(auto_script_config_content) || {}

    integration_server = nil
    if auto_script_config["integration_server_type"]
      server_type_id = @brpm_rest_client.get_id_for_project_server_type(auto_script_config["integration_server_type"])
      if server_type_id
        integration_server = integration_servers.find { |integration_server| integration_server["server_name_id"] == server_type_id } #TODO: support multiple integration servers of same type (user should pick one)

        if integration_server
          wrapper_script_content += "\n"
          wrapper_script_content += get_integration_server_template(integration_server["id"], integration_server["name"], auto_script_config["integration_server_type"])
        else
          BrpmAuto.log "WARNING - An integration server of type #{auto_script_config["integration_server_type"]} doesn't exist so not setting the integration server in the wrapper script."
        end
      else
        BrpmAuto.log "WARNING - Integration server type '#{auto_script_config["integration_server_type"]}' is not supported so not setting the integration server in the wrapper script."
      end
    end

    wrapper_script_content += "\n"
    wrapper_script_content += get_script_executor_template(automation_type, module_name, auto_script_name)

    module_friendly_name = get_module_friendly_name(module_name)
    auto_script_friendly_name = auto_script_config["friendly_name"] || "#{module_friendly_name} - #{auto_script_name.gsub("_", " ").capitalize}"
    if auto_script_config["automation_category"]
      automation_category = auto_script_config["automation_category"]
      create_automation_category_if_not_exists(automation_category)
    end

    script = {}
    script["name"] = auto_script_friendly_name
    script["description"] = auto_script_friendly_name
    script["automation_type"] = automation_type
    script["automation_category"] = module_friendly_name
    script["content"] = wrapper_script_content
    script["integration_id"] = integration_server["id"] if auto_script_config["integration_server_type"] and integration_server
    if automation_type == "ResourceAutomation"
      script["unique_identifier"] = auto_script_config["resource_id"] || auto_script_name
      script["render_as"] = auto_script_config["render_as"] || "List"
    end

    script = @brpm_rest_client.create_or_update_script(script)

    if script["aasm_state"] == "draft"
      BrpmAuto.log "Updating the aasm_state of the script to 'pending'..."
      script_to_update = {}
      script_to_update["id"] = script["id"]
      script_to_update["aasm_state"] = "pending"
      script = @brpm_rest_client.update_script_from_hash(script_to_update)
    end

    if script["aasm_state"] == "pending"
      BrpmAuto.log "Updating the aasm_state of the script to 'released'..."
      script_to_update = {}
      script_to_update["id"] = script["id"]
      script_to_update["aasm_state"] = "released"
      script = @brpm_rest_client.update_script_from_hash(script_to_update)
    end
  end

  def get_input_params_template(input_params_yaml)
    include_position_attribute = false
    if input_params_yaml.find {|_, param| param.has_key?("position")}
      include_position_attribute = true
    end

    template = <<EOR
# framework_version:
#   name: Framework version
#   required: no
EOR

    if include_position_attribute
      template += "#   position: A#{input_params_yaml.size + 1}:C#{input_params_yaml.size + 1}\n"
    end

    template += <<EOR
# module_version:
#   name: Module version
#   required: no
EOR

    if include_position_attribute
      template += "#   position: A#{input_params_yaml.size + 2}:C#{input_params_yaml.size + 2}\n"
    end

    template
  end

  def get_integration_server_template(integration_server_id, integration_server_name, integration_server_type)
    <<EOR
#=== #{integration_server_type} Integration Server: #{integration_server_name} ===#
# [integration_id=#{integration_server_id}]
#=== End ===#

params["SS_integration_dns"] = SS_integration_dns
params["SS_integration_username"] = SS_integration_username
params["SS_integration_password_enc"] = SS_integration_password_enc
params["SS_integration_details"] = YAML.load(SS_integration_details)
EOR
  end

  def get_script_executor_template(automation_type, module_name, auto_script_name)
    template = <<EOR
params["direct_execute"] = "true"

params["framework_version"] = nil if params["framework_version"].empty?
params["module_version"] = nil if params["module_version"].empty?

require "\#{ENV["BRPM_CONTENT_HOME"] || "\#{ENV["BRPM_HOME"]}/modules"}/gems/brpm_content-\#{params["framework_version"] || "latest"}/modules/framework/brpm_script_executor.rb"
EOR

    if automation_type == "Automation"

      template += <<EOR

BrpmScriptExecutor.execute_automation_script_from_gem("#{module_name}", "#{auto_script_name}", params)
EOR

    elsif automation_type == "ResourceAutomation"

      template += <<EOR

def execute(script_params, parent_id, offset, max_records)
  BrpmScriptExecutor.execute_resource_automation_script_from_gem("#{module_name}", "#{auto_script_name}", script_params, parent_id, offset, max_records)
end
EOR
    end

    template
  end
end