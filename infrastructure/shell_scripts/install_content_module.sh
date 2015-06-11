#!/bin/bash

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the installation."
    exit 1
fi

read -p "What is the location of the content module? You may specify either the location of a zip file on the local file system or the url of a github repo (e.g. https://github.com/BMC-RLM/brpm_module_mymodule.git)" LOCATION

if [ -z "$LOCATION" ]; then
  echo "The location was not specified. Aborting the installation."
  exit 1
fi

if [[ $LOCATION == *"github.com"* ]]; then
  echo "The location refers to a github repo."
  IS_GITHUB_LOCATION=true
else
  IS_GITHUB_LOCATION=false
  echo "The location refers to a file."
  if [ ! -f "$LOCATION" ]; then
    echo "The specified location is not a file. Aborting the installation."
    exit 1
  fi
fi

BASENAME=$(basename $LOCATION)
NAME=${BASENAME%.*}

CURRENT_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")
CONTENT_MODULES_PATH=$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos/modules
CONTENT_MODULE_PATH=$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos/modules/$NAME

if [ ! -d "$CONTENT_MODULES_PATH" ]; then
  echo "Creating directory $CONTENT_MODULES_PATH..."
  mkdir -p $CONTENT_MODULES_PATH
fi

if [ -d "$CONTENT_MODULE_PATH" ]; then
  DATE=$(date +"%Y%m%d%H%M")
  echo "Archiving current content module to ${CONTENT_MODULE_PATH}_${DATE}..."
  mv ${CONTENT_MODULE_PATH} ${CONTENT_MODULE_PATH}_${DATE}
fi

if [ "$IS_GITHUB_LOCATION" = true ]; then
  echo "Doing a 'git clone $LOCATION' on $CONTENT_MODULES_PATH..."
  tmp_dir=$(pwd)
  cd $CONTENT_MODULES_PATH
  git clone $LOCATION
  cd $tmp_dir
else
  echo "Unzipping $LOCATION..."
  unzip "$LOCATION" -d $CONTENT_MODULES_PATH

  if [ -d $CONTENT_MODULES_PATH/$NAME-master ]; then
    echo "Renaming the directory to $CONTENT_MODULE_PATH..."
    mv $CONTENT_MODULES_PATH/$NAME-master $CONTENT_MODULE_PATH
  fi
fi

echo "Done."
