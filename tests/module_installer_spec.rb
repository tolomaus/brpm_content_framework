require_relative "spec_helper"

describe 'Module installer' do
  before(:all) do
    raise "Module installation tests don't work under Bundler." if ENV["RUBYOPT"] and ENV["RUBYOPT"].include?("-rbundler/setup")

    setup_brpm_auto

    BrpmAuto.log "Creating ~/.brpm file..."
    create_brpm_file
  end

  before(:each) do
    module_installer = ModuleInstaller.new

    brpm_specs = Gem::Specification.find_all_by_name("brpm_module_brpm")

    brpm_specs.each do |brpm_spec|
      BrpmAuto.log "Module brpm_module_brpm (#{brpm_spec.version.to_s}) is already installed, uninstalling it..."
      module_installer.uninstall_module("brpm_module_brpm", brpm_spec.version.to_s)
    end
  end

  it 'should install the BRPM module from rubygems.org' do
    module_installer = ModuleInstaller.new
    module_installer.install_module("brpm_module_brpm")

    expect{Gem::Specification.find_by_name("brpm_module_brpm")}.not_to raise_error #(Gem::LoadError)
  end

  it 'should install a specific version of the BRPM module from rubygems.org' do
    module_installer = ModuleInstaller.new
    module_installer.install_module("brpm_module_brpm", "0.1.29")

    expect{Gem::Specification.find_by_name("brpm_module_brpm", Gem::Requirement.create(Gem::Version.new("0.1.29")))}.not_to raise_error #(Gem::LoadError)
  end

  it 'should install a BRPM module from a local gem file' do
    `wget https://rubygems.org/downloads/brpm_module_brpm-0.1.29.gem` unless File.exists?("./brpm_module_brpm-0.1.29.gem")

    module_installer = ModuleInstaller.new
    module_installer.install_module("./brpm_module_brpm-0.1.29.gem")

    expect{Gem::Specification.find_by_name("brpm_module_brpm", Gem::Requirement.create(Gem::Version.new("0.1.29")))}.not_to raise_error #(Gem::LoadError)
  end
end