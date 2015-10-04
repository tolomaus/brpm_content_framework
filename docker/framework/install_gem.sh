#!/usr/bin/env bash

gem install $MODULE -v $VERSION --ignore-dependencies
cd $GEM_HOME/gems/$MODULE-$VERSION
bundle install
rm -rf $GEM_HOME/cache