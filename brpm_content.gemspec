require "yaml"

config = YAML.load_file(File.join(File.dirname(__FILE__), "config.yml"))

Gem::Specification.new do |spec|
  spec.name          = File.basename(File.expand_path(File.dirname(__FILE__)))
  spec.version       = config["version"]
  spec.platform      = Gem::Platform::RUBY
  spec.license       = config["license"]
  spec.authors       = [config["author"]]
  spec.email         = config["email"]
  spec.homepage      = config["homepage"]
  spec.summary       = config["summary"]
  spec.description   = config["description"]

  spec.required_rubygems_version = "2.1.9"

  spec.add_runtime_dependency "rest-client"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "savon", '~>1.1.0'
  spec.add_runtime_dependency 'capistrano', '2.15.5'

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.files         = `git ls-files`.split("\n")
  spec.require_path  = 'modules/framework'

  spec.executables   = spec.files.grep(%r{^modules/framework/bin/}).map{ |f| File.basename(f) }
  spec.bindir        = "modules/framework/bin"
end
