# Copied from https://github.com/mitchellh/vagrant-aws/blob/master/vagrant-aws.gemspec
require "yaml"

config = YAML.load_file(File.expand_path("#{File.dirname(__FILE__)}/modules/framework/config.yml"))

Gem::Specification.new do |s|
  s.name          = File.basename(File.expand_path(File.dirname(__FILE__)))
  s.version       = config["version"]
  s.platform      = Gem::Platform::RUBY
  s.license       = "GNU General Public License v2.0"
  s.authors       = [config["author"]]
  s.email         = config["email"]
  s.homepage      = config["homepage"]
  s.summary       = config["summary"]
  s.description   = config["description"]

  s.required_rubygems_version = ">=1.9.3"

  if config["dependencies"]
    config["dependencies"].each do |dependency, values|
      s.add_runtime_dependency dependency, values["version"]
    end
  end

  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "savon", '~>1.1.0'
  s.add_runtime_dependency 'capistrano', '2.15.5'

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  # The following block of code determines the files that should be included
  # in the gem. It does this by reading all the files in the directory where
  # this gemspec is, and parsing out the ignored files from the gitignore.
  # Note that the entire gitignore(5) syntax is not supported, specifically
  # the "!" syntax, but it should mostly work correctly.
  root_path      = File.dirname(__FILE__)
  all_files      = Dir.chdir(root_path) { Dir.glob("**/{*,.*}") }
  all_files.reject! { |file| [".", ".."].include?(File.basename(file)) }
  gitignore_path = File.join(root_path, ".gitignore")
  gitignore      = File.readlines(gitignore_path)
  gitignore.map!    { |line| line.chomp.strip }
  gitignore.reject! { |line| line.empty? || line =~ /^(#|!)/ }

  unignored_files = all_files.reject do |file|
    # Ignore any directories, the gemspec only cares about files
    next true if File.directory?(file)

    # Ignore any paths that match anything in the gitignore. We do
    # two tests here:
    #
    #   - First, test to see if the entire path matches the gitignore.
    #   - Second, match if the basename does, this makes it so that things
    #     like '.DS_Store' will match sub-directories too (same behavior
    #     as git).
    #
    gitignore.any? do |ignore|
      File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
        File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
    end
  end

  s.files         = unignored_files
  s.require_path  = 'lib'
end
