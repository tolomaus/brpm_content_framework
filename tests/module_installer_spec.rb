describe 'Module installer' do
  before(:all) do
    raise "Module installation tests don't work under Bundler." if ENV["RUBYOPT"] and ENV["RUBYOPT"].include?("-rbundler/setup")
    raise "$BRPM_STUB_HOME is not set" unless ENV["BRPM_STUB_HOME"]

    brpm_version = "4.6.00.00"
    ENV["BRPM_HOME"] = ENV["BRPM_STUB_HOME"]

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

    require_relative "spec_helper"

    setup_brpm_auto

    BrpmAuto.log "Creating ~/.brpm file..."
    create_brpm_file

    @module_name = "brpm_module_test"
    @module_version = "0.1.3"
  end

  before(:each) do
    module_installer = ModuleInstaller.new

    module_specs = Gem::Specification.find_all_by_name(@module_name)

    module_specs.each do |module_spec|
      if module_spec.loaded_from.start_with?(ENV["BRPM_HOME"])
        BrpmAuto.log "Module #{@module_name} (#{module_spec.version.to_s}) is already installed, uninstalling it..."
        module_installer.uninstall_module(@module_name, module_spec.version.to_s)
      end
    end
  end

  it "should install a module from rubygems.org" do
    module_installer = ModuleInstaller.new
    module_installer.install_module(@module_name)

    expect{Gem::Specification.find_by_name(@module_name)}.not_to raise_error #(Gem::LoadError)
  end

  it "should install a specific version of a module from rubygems.org" do
    module_installer = ModuleInstaller.new
    module_installer.install_module(@module_name, @module_version)

    expect{Gem::Specification.find_by_name(@module_name, Gem::Requirement.create(Gem::Version.new(@module_version)))}.not_to raise_error #(Gem::LoadError)
  end

  it "should install a module from a local gem file" do
    `mkdir -p temp && cd temp && wget https://rubygems.org/downloads/#{@module_name}-#{@module_version}.gem` unless File.exists?("temp/#{@module_name}-#{@module_version}.gem")

    module_installer = ModuleInstaller.new
    module_installer.install_module("temp/#{@module_name}-#{@module_version}.gem")

    expect{Gem::Specification.find_by_name(@module_name, Gem::Requirement.create(Gem::Version.new(@module_version)))}.not_to raise_error #(Gem::LoadError)
  end
end