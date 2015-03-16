#!/bin/bash

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the installation."
    exit 1
fi

CURRENT_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")
CONTENT_REPO_PATH=$BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos/brpm_content

echo "Doing a git clone git@github.com:BMC-RLM/brpm_content.git on $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos..."
tmp_dir=$(pwd)
mkdir -p $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos
cd $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/git_repos
git clone git@github.com:BMC-RLM/brpm_content.git
cd $tmp_dir

mkdir -p $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/v2
cp $CONTENT_REPO_PATH/framework/bootstrap.rb $BRPM_HOME/releases/$CURRENT_VERSION/RPM/lib/script_support/v2
cp $CONTENT_REPO_PATH/framework/log.html $BRPM_HOME/automation_results

mkdir -p /root/shell_scripts/v2
cp $CONTENT_REPO_PATH/infrastructure/shell_scripts/* /root/shell_scripts/v2

echo "Done."
