#!/bin/bash

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the installation."
    exit 1
fi

read -p "What is the location of the content zip file? (empty will do a git clone from github)" LOCATION

if [ ! -z "$LOCATION" ]; then
  if [ ! -f "$LOCATION" ]; then
    echo "The specified location is not a file. Aborting the installation."
    exit 1
  fi
fi

CURRENT_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")
CONTENT_REPO_PATH=$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos/brpm_content

if [ ! -d "$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos" ]; then
  echo "Creating directory $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos..."
  mkdir -p $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos
fi

if [ -d "$CONTENT_REPO_PATH" ]; then
  DATE=$(date +"%Y%m%d%H%M")
  echo "Archiving current content repo to ${CONTENT_REPO_PATH}_${DATE}..."
  mv ${CONTENT_REPO_PATH} ${CONTENT_REPO_PATH}_${DATE}
fi

if [ -z "$LOCATION" ]; then
  echo "Doing a git clone git@github.com:BMC-RLM/brpm_content.git on $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos..."
  tmp_dir=$(pwd)
  mkdir -p $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos
  cd $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos
  git clone https://github.com/BMC-RLM/brpm_content.git
  cd $tmp_dir
else
  echo "Unzipping $LOCATION..."
  unzip "$LOCATION" -d $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos

  echo "Renaming the directory to $CONTENT_REPO_PATH..."
  mv $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos/brpm_content-master $CONTENT_REPO_PATH
fi

cp $CONTENT_REPO_PATH/framework/bootstrap.rb $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support
cp $CONTENT_REPO_PATH/framework/log.html $BRPM_HOME/automation_results

if [ ! -d "/root/shell_scripts" ]; then
  mkdir -p /root/shell_scripts
fi

cp $CONTENT_REPO_PATH/infrastructure/shell_scripts/* /root/shell_scripts

echo "Done."

echo "Make sure that the following item is added to Metadata > Lists > AutomationErrors: '******** ERROR ********'"