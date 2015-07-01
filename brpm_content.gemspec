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

  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "savon", '~>1.1.0'
  s.add_runtime_dependency 'capistrano', '2.15.5'

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  s.files         = `git ls-files`.split("\n")
  s.require_path  = 'modules/framework'
end
