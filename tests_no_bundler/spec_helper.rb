require "fileutils"

def setup_gem_env
  raise "$BRPM_STUB_HOME is not set" unless ENV["BRPM_STUB_HOME"]

  ENV["BRPM_HOME"] = ENV["BRPM_STUB_HOME"]
  ENV["GEM_HOME"] = "#{ENV["BRPM_HOME"]}/modules"
end

def setup_modules_env
  raise "Module installer tests don't work under Bundler." if ENV["RUBYOPT"] and ENV["RUBYOPT"].include?("-rbundler/setup")
  brpm_version = "4.6.00.00"

  FileUtils.mkdir_p "#{ENV["BRPM_HOME"]}/modules"
  FileUtils.mkdir_p "#{ENV["BRPM_HOME"]}/server/jboss/standalone/deployments"
  FileUtils.mkdir_p "#{ENV["BRPM_HOME"]}/releases/#{brpm_version}/RPM"

  knob=<<EOR
---
application:
  root: #{ENV["BRPM_HOME"]}/releases/#{brpm_version}/RPM
environment:
  RAILS_ENV: production
web:
  context: /brpm
EOR

  File.open("#{ENV["BRPM_HOME"]}/server/jboss/standalone/deployments/RPM-knob.yml", "w") do |file|
    file.puts(knob)
  end

  version_content=<<EOR
$VERSION=#{brpm_version}
EOR

  File.open("#{ENV["BRPM_HOME"]}/releases/#{brpm_version}/RPM/VERSION", "w") do |file|
    file.puts(version_content)
  end
end

def get_default_params
  params = {}
  params['unit_test'] = 'true'
  params['also_log_to_console'] = 'true'

  params['brpm_url'] = 'http://brpm-content.pulsar-it.be:8088/brpm'
  params['brpm_api_token'] = ENV["BRPM_API_TOKEN"]

  params['output_dir'] = "/tmp/brpm_content"

  params
end

def setup_brpm_auto
  require_relative "../lib/brpm_auto" #require_relative because we can't run inside bundler, we can't run inside bundler because we need the brpm_module_test which is not included in the brpm_content_framework Gemfile
  BrpmAuto.setup(get_default_params)
end

def create_brpm_file
  if File.exists?("~/.brpm")
    FileUtils.rm("~/.brpm")
  end

  params = get_default_params
  brpm_params = {}
  brpm_params["brpm_url"] = params["brpm_url"]
  brpm_params["brpm_api_token"] = params["brpm_api_token"]

  File.open(File.expand_path("~/.brpm"), "w") do |file|
    file.puts(brpm_params.to_yaml)
  end
end

def setup_brpm_connectivity
  BrpmAuto.log "Creating ~/.brpm file..."
  create_brpm_file

  brpm_specs = Gem::Specification.find_all_by_name("brpm_module_brpm")
  if brpm_specs.empty?
    Gem.install("brpm_module_brpm")
  end
end
