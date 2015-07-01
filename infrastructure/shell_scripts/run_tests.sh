#!/usr/bin/env bash
failed_tests=false

bundle exec rspec ./modules/framework/tests --format documentation --color
rc=$?; if [ $rc != 0 ]; then failed_tests=true; fi

bundle exec rspec ./modules/brpm/tests --format documentation --color
rc=$?; if [ $rc != 0 ]; then failed_tests=true; fi

bundle exec rspec ./modules/jira/tests --format documentation --color
rc=$?; if [ $rc != 0 ]; then failed_tests=true; fi

bundle exec rspec ./modules/bladelogic/tests --format documentation --color
rc=$?; if [ $rc != 0 ]; then failed_tests = true; fi

if [ "$failed_tests" = true ] ; then
  echo "Failed tests were found, exiting with -1."
  exit -1;
fi