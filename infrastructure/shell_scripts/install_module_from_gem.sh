#!/bin/bash

USAGE="install_module_from_gem.sh <module name> [<module version>]"

MODULE_NAME=$1
MODULE_VERSION=$2

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the installation."
    exit 1
fi

if [ -z "$MODULE_NAME" ]; then
    echo "Module name is not specified. Aborting the patch installation."
    echo "Usage: $USAGE"
    exit 1
fi

. $BRPM_HOME/bin/setenv.sh

jruby <<-EORUBY
require "rubygems"
require "bundler"

ENV["GEM_HOME"] = ENV["BRPM_CONTENT_HOME"] || "#{ENV["BRPM_HOME"]}/modules"
puts "GEM_HOME: #{ENV["GEM_HOME"]}"

Gem.paths = ENV

specs = Gem.install "$MODULE_NAME", { :ignore_dependencies => true }
spec = specs[0] #no idea why this returns an array

if File.exists?(File.join(spec.gem_dir, "Gemfile.lock"))
  Dir.chdir(spec.gem_dir)
  `GEM_HOME=#{ENV["GEM_HOME"]} && bundle install`
else
  specs = Gem.install "$MODULE_NAME"
end

# set symlink to brpm_content-latest if a higher version was installed
version = Gem.latest_version_for("brpm_content")
EORUBY

echo "Done."
