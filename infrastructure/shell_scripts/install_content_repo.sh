#!/bin/bash

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the installation."
    exit 1
fi

INSTALL=${INSTALL:-LOCAL}

if [ $INSTALL = "LOCAL" ]; then
  read -p "What is the location of the content zip file? (leave empty to do a git clone from github)" LOCATION

  if [ ! -z "$LOCATION" ]; then
    if [ ! -f "$LOCATION" ]; then
      echo "The specified location is not a file. Aborting the installation."
      exit 1
    fi
  fi
fi

CURRENT_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")
CONTENT_REPOS_PATH=$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos
CONTENT_REPO_PATH=$CONTENT_REPOS_PATH/brpm_content

if [ ! -d "$CONTENT_REPOS_PATH" ]; then
  echo "Creating directory $CONTENT_REPOS_PATH..."
  mkdir -p $CONTENT_REPOS_PATH
fi

if [ -d "$CONTENT_REPO_PATH" ]; then
  DATE=$(date +"%Y%m%d%H%M")
  echo "Archiving current content repo to ${CONTENT_REPO_PATH}_${DATE}..."
  mv ${CONTENT_REPO_PATH} ${CONTENT_REPO_PATH}_${DATE}
fi

if [ -z "$LOCATION" ]; then
  echo "Doing a 'git clone https://github.com/BMC-RLM/brpm_content.git' on $CONTENT_REPOS_PATH..."
  tmp_dir=$(pwd)
  cd $CONTENT_REPOS_PATH
  git clone https://github.com/BMC-RLM/brpm_content.git
  cd $tmp_dir
else
  echo "Unzipping $LOCATION..."
  unzip "$LOCATION" -d $CONTENT_REPOS_PATH

  echo "Renaming the directory to $CONTENT_REPO_PATH..."
  mv $CONTENT_REPOS_PATH/brpm_content-master $CONTENT_REPO_PATH
fi

cp $CONTENT_REPO_PATH/modules/framework/log.html $BRPM_HOME/automation_results

if [ ! -d "/root/shell_scripts" ]; then
  mkdir -p /root/shell_scripts
fi

cp $CONTENT_REPO_PATH/infrastructure/shell_scripts/* /root/shell_scripts

echo "Done."

echo "Make sure that the following item is added to Metadata > Lists > AutomationErrors: '******** ERROR ********'"