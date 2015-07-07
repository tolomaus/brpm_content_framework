#!/bin/bash

# This script is case wrapper around gem install and exists for the following reasons:
# 1) We want to keep the module gems and their dependencies in case separate location than the gems that are used by BRPM so we need to override the install dir
# 2) In case the module gems that needs to be installed comes with a gemfile.lock case "bundle install" should be executed to make sure the locked gem versions are installed
# 3) Make sure that brpm_content-latest always symlinks to the latest installed version

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

brpm_content_home = ENV["BRPM_CONTENT_HOME"] || "#{ENV["BRPM_HOME"]}/modules"

ENV["GEM_HOME"] = brpm_content_home
Gem.paths = ENV
puts "GEM_HOME=#{ENV["GEM_HOME"]}"

puts "gem install $MODULE_NAME"
specs = Gem.install "$MODULE_NAME"
spec = specs.last

gemfile = File.join(spec.gem_dir, "Gemfile")
gemfile_lock = File.join(spec.gem_dir, "Gemfile.lock")

if File.exists?(gemfile) && File.exists?(gemfile_lock)
  puts "Found a Gemfile.lock."
  #require 'rubygems/user_interaction'
  #require 'thor/base'
  #Bundler.ui = Bundler::UI::Shell.new
  #Bundler::Installer.install("/Users/niek/temp/modules", Bundler.definition, {:gemfile => gemfile})
  puts "GEM_HOME=#{brpm_content_home} && bundle install --gemfile #{gemfile}"
  `GEM_HOME=#{brpm_content_home} && bundle install --gemfile #{gemfile}`
end

# set symlink to brpm_content-latest if a higher version was installed
puts ""

spec_of_latest_version = Gem::Specification.find_all_by_name("brpm_content").sort_by{ |g| [g.name.downcase, g.version] }.last

FileUtils.ln_sf("#{brpm_content_home}/gems/brpm_content-#{spec_of_latest_version.version}", "#{brpm_content_home}/gems/brpm_content-latest")
EORUBY

echo "Done."
