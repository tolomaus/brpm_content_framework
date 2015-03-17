#!/bin/bash

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the installation."
    exit 1
fi

if [ ! -f ~/brpm_content-master.zip ]; then
    echo "~/brpm_content-master.zip not found. Aborting the installation."
    exit 1
fi

CURRENT_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")
CONTENT_REPO_PATH=$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos/brpm_content

if [ ! -d "$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos" ]; then
  echo "Creating directory $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos..."
  mkdir -p $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos
fi

if [ -d "$CONTENT_REPO_PATH" ]; then
  echo "Archiving current content repo to ${CONTENT_REPO_PATH}_${DATE}..."
  DATE=$(date +"%Y%m%d%H%M")
  mv ${CONTENT_REPO_PATH} ${CONTENT_REPO_PATH}_${DATE}
fi

echo "Unzipping ~/brpm_content-master.zip..."
unzip ~/brpm_content-master.zip -d $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos

echo "Renaming the directory to $CONTENT_REPO_PATH..."
mv $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos/brpm_content-master $CONTENT_REPO_PATH

if [ ! -d "$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support" ]; then
  echo "Creating directory $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support..."
  mkdir -p $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support
fi

cp $CONTENT_REPO_PATH/framework/bootstrap.rb $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support
cp $CONTENT_REPO_PATH/framework/log.html $BRPM_HOME/automation_results

if [ ! -d "/root/shell_scripts" ]; then
  mkdir -p /root/shell_scripts
fi

cp $CONTENT_REPO_PATH/infrastructure/shell_scripts/* /root/shell_scripts

echo "Done."