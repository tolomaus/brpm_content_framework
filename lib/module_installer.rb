require "rubygems"
require 'rubygems/package'
require 'rubygems/installer'
require "bundler"

class ModuleInstaller
  def initialize
    set_gem_home
  end

  def install_module(module_name_or_path, module_version = nil)
    brpm_content_spec = nil

    if true #TODO: support no-gem-install mode
      module_spec, specs = install_gem(module_name_or_path, module_version)

      brpm_content_spec = specs.find { |spec| spec.name == "brpm_content" } if specs

      install_bundle_if_necessary(module_spec)
    else
      module_name = module_name_or_path
      module_spec = Gem::Specification.find_by_name(module_name)
    end

    if brpm_installed_locally?
      BrpmAuto.log "A BRPM instance is installed locally"

      if brpm_content_spec
        if brpm_content_spec.version > Gem::Version.new(BrpmAuto.version) or ! File.exist?(get_symlink_path)
          BrpmAuto.log "Updating the symlink to brpm_content-latest..."
          update_symlink_to_brpm_content(brpm_content_spec.gem_dir)
        end

        if brpm_content_spec.version > Gem::Version.new(BrpmAuto.version) or ! File.exist?("#{ENV["BRPM_HOME"]}/automation_results/log.html")
          BrpmAuto.log "Copying the log.html file to te automation_results directory..."
          FileUtils.cp("#{brpm_content_spec.gem_dir}/infrastructure/log.html", "#{ENV["BRPM_HOME"]}/automation_results")
        end
      end

      BrpmAuto.log "Preparing the connectivity to BRPM..."
      if prepare_brpm_connection
        BrpmAuto.log "Creating an automation error for '******** ERROR ********' if one doesn't exist yet..."
        create_automation_error_if_not_exists("******** ERROR ********")

        module_friendly_name = get_module_friendly_name(module_spec)
        BrpmAuto.log "Creating an automation category for #{module_friendly_name} if one doesn't exist yet..."
        create_automation_category_if_not_exists(module_friendly_name)

        BrpmAuto.log "Retrieving the integration servers..."
        integration_servers = @brpm_rest_client.get_project_servers

        BrpmAuto.log "Installing the automation script wrappers in the local BRPM instance..."
        failed_scripts = each_auto_script_wrapper(module_spec.gem_dir) do |auto_script_path, automation_type|
          BrpmAuto.log "Installing automation script wrapper for script #{auto_script_path}..."
          install_auto_script_wrapper(auto_script_path, automation_type, module_spec.name, module_friendly_name, integration_servers)
        end

        if failed_scripts.size > 0
          return false
        end
      end
    end
  end

  def uninstall_module(module_name, module_version)
    if brpm_installed_locally?
      BrpmAuto.log "A BRPM instance is installed locally"

      BrpmAuto.log "Preparing the connectivity to BRPM..."
      if prepare_brpm_connection
        version_req = Gem::Requirement.create(Gem::Version.new(module_version))
        module_spec = Gem::Specification.find_by_name(module_name, version_req)

        module_friendly_name = get_module_friendly_name(module_spec)

        BrpmAuto.log "Uninstalling the automation script wrappers in the local BRPM instance..."
        failed_scripts = each_auto_script_wrapper(module_spec.gem_dir) do |auto_script_path, automation_type|
          BrpmAuto.log "Uninstalling automation script wrapper for script #{auto_script_path}..."
          uninstall_auto_script_wrapper(auto_script_path, automation_type, module_friendly_name)
        end

        if failed_scripts.size > 0
          BrpmAuto.log "Aborting the uninstall."
          return false
        end

        BrpmAuto.log "Deleting the automation category for #{module_friendly_name}..."
        delete_automation_category(module_friendly_name)
      end
    end

    BrpmAuto.log "Uninstalling gem #{module_name} #{module_version}..."
    BrpmAuto.log `gem uninstall #{module_name} -v #{module_version} -x`

    return true
  end

  def module_installed?(module_name, module_version = nil)
    Gem::Specification.find_by_name(module_name).size > 0
  end

  private

  def prepare_brpm_connection
    brpm_file = File.expand_path("~/.brpm")

    brpm_config = nil
    if File.exists?(brpm_file)
      brpm_config = YAML.load_file(brpm_file)
    end

    if brpm_config
      unless brpm_config["brpm_url"] and brpm_config["brpm_api_token"]
        BrpmAuto.log "WARNING - Properties brpm_url and/or brpm_api_token don't exist in file ~/.brpm so not installing the automation script wrappers in BRPM. If you want to install them the next time you should add brpm_url and brpm_api_token properties in yaml format in file ~/.brpm."
        return false
      end
    else
      BrpmAuto.log "WARNING - File ~/.brpm doesn't exist so not installing the automation script wrappers in BRPM. If you want to install them the next time you should create this file and add brpm_url and brpm_api_token properties in yaml format."
      return false
    end

    begin
      BrpmAuto.log "Loading brpm_module_brpm..."
      BrpmAuto.require_module "brpm_module_brpm"
    rescue Gem::GemNotFoundException
      BrpmAuto.log "WARNING - Module brpm_module_brpm is not installed so not installing the automation script wrappers in BRPM."
      return false
    end

    @brpm_rest_client = BrpmRestClient.new(brpm_config["brpm_url"], brpm_config["brpm_api_token"])
    true
  end

  def install_gem(module_name_or_path, module_version)
    if module_name_or_path =~ /\.gem$/ and File.file? module_name_or_path
      BrpmAuto.log "Installing gem #{module_name_or_path}#{module_version.nil? ? "" : " " + module_version} from file..."
      require 'rubygems/name_tuple'
      source = Gem::Source::SpecificFile.new module_name_or_path
      module_spec = source.spec

      gem = source.download module_spec

      inst = Gem::Installer.new gem
      inst.install
      BrpmAuto.log "Done."
    else
      BrpmAuto.log "Installing gem #{module_name_or_path}#{module_version.nil? ? "" : " " + module_version}..."
      version_req = module_version ? Gem::Requirement.create(Gem::Version.new(module_version)) : Gem::Requirement.default
      specs = Gem.install(module_name_or_path, version_req)

      BrpmAuto.log "Installed gems:"
      specs.each do |spec|
        BrpmAuto.log "  - #{spec.name} #{spec.version}"
      end

      module_spec = specs.find { |spec| spec.name == module_name_or_path}
    end

    return module_spec, specs
  end

  def set_gem_home
    if BrpmAuto.run_from_brpm or BrpmAuto.params.unit_test
      # we need to override the GEM_HOME env var, otherwise the gems will be installed in BRPM's own gemset
      ENV["GEM_HOME"] = BrpmAuto.get_gems_root_path
      Gem.paths = ENV
    end
  end

  def install_bundle_if_necessary(spec)
    gemfile = File.join(spec.gem_dir, "Gemfile")
    gemfile_lock = File.join(spec.gem_dir, "Gemfile.lock")

    if File.exists?(gemfile) && File.exists?(gemfile_lock)
      if BrpmAuto.run_from_brpm or BrpmAuto.params.unit_test
        command = "cd #{spec.gem_dir}; export GEM_HOME=#{BrpmAuto.get_gems_root_path}; bundle install"
      else
        command = "cd #{spec.gem_dir}; bundle install"
      end
      BrpmAuto.log "Found a Gemfile.lock so executing command '#{command}'..."
      result = BrpmAuto.execute_shell(command)

      BrpmAuto.log result["stdout"] if result["stdout"] and !result["stdout"].empty?
      unless result["status"] == 0
        raise result["stderr"]
      end
    end
  end

  def get_symlink_path
    "#{ENV["GEM_HOME"]}/gems/brpm_content-latest"
  end

  def update_symlink_to_brpm_content(brpm_content_path)
    new_version_path = brpm_content_path
    symlink_path = get_symlink_path

    BrpmAuto.log "Linking #{symlink_path} to #{new_version_path}..."
    result = BrpmAuto.execute_shell("ln -sfn #{new_version_path} #{symlink_path}")
    BrpmAuto.log result["stdout"] if result["stdout"] and !result["stdout"].empty?
    unless result["status"] == 0
      raise result["stderr"]
    end
  end

  def brpm_installed_locally?
    ENV["BRPM_HOME"] and !ENV["BRPM_HOME"].empty?
  end

  def get_module_friendly_name(module_spec)
    module_config = YAML.load_file("#{module_spec.gem_dir}/config.yml")

    module_config["name"] || "#{module_spec.name.sub("brpm_module_", "").capitalize}"
  end

  def create_automation_error_if_not_exists(automation_error)
    list_item = @brpm_rest_client.get_list_item_by_name("AutomationErrors", automation_error)

    unless list_item
      BrpmAuto.log "Automation error #{automation_error} doesn't exist yet, so creating it now..."
      list_item = {}
      list_item["list_id"] = @brpm_rest_client.get_list_by_name("AutomationErrors")["id"]
      list_item["value_text"] = automation_error
      @brpm_rest_client.create_list_item_from_hash(list_item)
    end
  end

  def create_automation_category_if_not_exists(module_friendly_name)
    list_item = @brpm_rest_client.get_list_item_by_name("AutomationCategory", module_friendly_name)

    unless list_item
      BrpmAuto.log "Automation category #{module_friendly_name} doesn't exist yet, so creating it now..."
      list_item = {}
      list_item["list_id"] = @brpm_rest_client.get_list_by_name("AutomationCategory")["id"]
      list_item["value_text"] = module_friendly_name
      @brpm_rest_client.create_list_item_from_hash(list_item)
    end
  end

  def delete_automation_category(module_friendly_name)
    #TODO: first check if there are any manually created automation scripts added to this automation category. If yes then dont delete it
    list_item = @brpm_rest_client.get_list_item_by_name("AutomationCategory", module_friendly_name)

    if list_item
      @brpm_rest_client.archive_list_item(list_item["id"])
      @brpm_rest_client.delete_list_item(list_item["id"])
    end
  end

  def each_auto_script_wrapper(module_path)
    # For resource automations
    resource_automation_dir = "#{module_path}/resource_automations"
    resource_automation_script_paths = Dir.glob("#{resource_automation_dir}/*.rb")

    failed_scripts = []
    if resource_automation_script_paths.size > 0
      resource_automation_script_paths.each do |auto_script_path|
        begin
          yield auto_script_path, "ResourceAutomation"
        rescue Exception => e
          failed_scripts << auto_script_path
          BrpmAuto.log_error(e)
          BrpmAuto.log "\n\t" + e.backtrace.join("\n\t")
        end
      end
    end

    # For automations
    automation_dir = "#{module_path}/automations"
    automation_script_paths = Dir.glob("#{automation_dir}/*.rb")

    if automation_script_paths.size > 0
      automation_script_paths.each do |auto_script_path|
        begin
          yield auto_script_path, "Automation"
        rescue Exception => e
          failed_scripts << auto_script_path
          BrpmAuto.log_error(e)
          BrpmAuto.log "\n\t" + e.backtrace.join("\n\t")
        end
      end
    end

    if failed_scripts.size > 0
      BrpmAuto.log "The following wrapper scripts generated errors:"
      failed_scripts.each do |failed_script|
        BrpmAuto.log "  - #{failed_script}"
      end
    end

    failed_scripts
  end

  def install_auto_script_wrapper(auto_script_path, automation_type, module_name, module_friendly_name, integration_servers)
    auto_script_config = get_auto_script_config(auto_script_path, module_friendly_name)

    BrpmAuto.log "Installing the wrapper script for automation script #{auto_script_config["name"]} (friendly name: #{auto_script_config["friendly_name"]}, automation type: #{automation_type})..."

    if automation_type == "Automation"
      add_version_params(auto_script_config["params"])
    end

    wrapper_script_content = ""
    if auto_script_config["params"].size > 0
      params_content = auto_script_config["params"].to_yaml
      params_content.sub!("---\n", "") # Remove the yaml document separator line
      params_content.gsub!(/(^)+/, "# ") # Prepend "# " to each line
      wrapper_script_content = "###\n#{params_content}###\n"
    end

    integration_server = nil
    if auto_script_config["integration_server_type"]
      server_type_id = @brpm_rest_client.get_id_for_project_server_type(auto_script_config["integration_server_type"])
      if server_type_id
        integration_server = integration_servers.find { |integr_server| integr_server["server_name_id"] == server_type_id } #TODO: support multiple integration servers of same type (user should pick one)
      else
        integration_server = integration_servers.find { |integr_server| integr_server["name"].include?(auto_script_config["integration_server_type"]) } #TODO: support multiple integration servers of same type (user should pick one)
      end

      if integration_server
        wrapper_script_content += "\n"
        wrapper_script_content += get_integration_server_template(integration_server["id"], integration_server["name"], auto_script_config["integration_server_type"])
      else
        BrpmAuto.log "WARNING - An integration server of type #{auto_script_config["integration_server_type"]} (or that has #{auto_script_config["integration_server_type"]} in its name if the integration server type is not supported) doesn't exist so not setting the integration server in the wrapper script."
      end
    end

    wrapper_script_content += "\n"
    wrapper_script_content += get_script_executor_template(automation_type, module_name, auto_script_config["name"])

    script = {}
    script["name"] = auto_script_config["friendly_name"]
    script["description"] = auto_script_config["description"] || ""
    script["automation_type"] = automation_type
    script["automation_category"] = module_friendly_name
    script["content"] = wrapper_script_content
    script["integration_id"] = integration_server["id"] if auto_script_config["integration_server_type"] and integration_server
    if automation_type == "ResourceAutomation"
      script["unique_identifier"] = auto_script_config["resource_id"] || auto_script_config["name"]
      script["render_as"] = auto_script_config["render_as"] || "List"
    end

    script = @brpm_rest_client.create_or_update_script(script)

    if script["aasm_state"] == "draft"
      BrpmAuto.log "Updating the aasm_state of the wrapper script to 'pending'..."
      script_to_update = {}
      script_to_update["id"] = script["id"]
      script_to_update["aasm_state"] = "pending"
      script = @brpm_rest_client.update_script_from_hash(script_to_update)
    end

    if script["aasm_state"] == "pending"
      BrpmAuto.log "Updating the aasm_state of the wrapper script to 'released'..."
      script_to_update = {}
      script_to_update["id"] = script["id"]
      script_to_update["aasm_state"] = "released"
      script = @brpm_rest_client.update_script_from_hash(script_to_update)
    end

    if script["aasm_state"] == "retired"
      BrpmAuto.log "Updating the aasm_state of the wrapper script to 'released'..."
      script_to_update = {}
      script_to_update["id"] = script["id"]
      script_to_update["aasm_state"] = "released"
      script = @brpm_rest_client.update_script_from_hash(script_to_update)
    end
  end

  def uninstall_auto_script_wrapper(auto_script_path, automation_type, module_friendly_name)
    auto_script_config = get_auto_script_config(auto_script_path, module_friendly_name)

    script = @brpm_rest_client.get_script_by_name(auto_script_config["friendly_name"])

    unless script
      BrpmAuto.log "Script #{auto_script_config["friendly_name"]} was not found, probably already deleted. Continuing."
      return
    end

    if script["aasm_state"] == "released"
      BrpmAuto.log "Updating the aasm_state of the wrapper script to 'retired'..."
      script_to_update = {}
      script_to_update["id"] = script["id"]
      script_to_update["aasm_state"] = "retired"
      script = @brpm_rest_client.update_script_from_hash(script_to_update)
    end

    if script["aasm_state"] == "retired"
      BrpmAuto.log "Updating the aasm_state of the wrapper script to 'archived'..."
      script_to_update = {}
      script_to_update["id"] = script["id"]
      script_to_update["aasm_state"] = "archived"
      script = @brpm_rest_client.update_script_from_hash(script_to_update)
    end

    if script["aasm_state"] == "archived_state"
      BrpmAuto.log "Deleting the wrapper script..."
      @brpm_rest_client.delete_script(script["id"])
    else
      raise "Script #{auto_script_config["friendly_name"]} is not in aasm_state 'archived' so unable to delete it."
    end
  end

  def get_auto_script_config(auto_script_path, module_friendly_name)
    auto_script_name = File.basename(auto_script_path, ".rb")
    auto_script_config_path = "#{File.dirname(auto_script_path)}/#{auto_script_name}.meta"

    auto_script_config_content = File.exists?(auto_script_config_path) ? File.read(auto_script_config_path) : ""
    auto_script_config = YAML.load(auto_script_config_content) || {}
    auto_script_config["params"] = auto_script_config["params"] || {}
    auto_script_config["name"] = File.basename(auto_script_path, ".rb")
    auto_script_config["friendly_name"] = auto_script_config["friendly_name"] || "#{module_friendly_name} - #{auto_script_config["name"].gsub("_", " ").capitalize}"

    auto_script_config
  end

  def add_version_params(auto_script_params)
    include_position_attribute = false
    if auto_script_params.find { |_, param| param.has_key?("position") }
      include_position_attribute = true
    end

    input_params = auto_script_params.select do |_, param|
      type = param["type"] || "in"
      ! type.start_with?("out")
    end

    module_version_param = {}
    module_version_param["name"] = "module_version"
    module_version_param["required"] = false
    module_version_param["position"] = "A#{input_params.size + 1}:C#{input_params.size + 1}" if include_position_attribute
    auto_script_params["module_version"] = module_version_param

    framework_version_param = {}
    framework_version_param["name"] = "framework_version"
    framework_version_param["required"] = false
    framework_version_param["position"] = "A#{input_params.size + 2}:C#{input_params.size + 2}" if include_position_attribute
    auto_script_params["framework_version"] = framework_version_param
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

BrpmScriptExecutor.execute_automation_script("#{module_name}", "#{auto_script_name}", params)
EOR

    elsif automation_type == "ResourceAutomation"

      template += <<EOR

def execute(script_params, parent_id, offset, max_records)
  BrpmScriptExecutor.execute_resource_automation_script("#{module_name}", "#{auto_script_name}", script_params, parent_id, offset, max_records)
end
EOR
    end

    template
  end
end