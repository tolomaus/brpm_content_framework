#!/usr/bin/env bash

gem install $MODULE -v $VERSION || { echo 'gem install failed' ; exit 1; }

cd $GEM_HOME/gems/$MODULE-$VERSION
bundle install || { echo 'bundle install failed' ; exit 1; }

rm -rf $GEM_HOME/cache