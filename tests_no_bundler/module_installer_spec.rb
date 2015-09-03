require_relative "spec_helper"

describe 'Module installer' do
  before(:all) do
    setup_gem_env
    setup_modules_env
    setup_brpm_auto
    setup_brpm_connectivity

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