#!/bin/sh

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the script."
    exit 1
fi

# mandatory settings
export WEBHOOK_RECEIVER_PORT=8089
export WEBHOOK_RECEIVER_MOUNT_POINT=webhooks
export WEBHOOK_RECEIVER_LOG_FILE=/tmp/webhook_receiver.log
export WEBHOOK_RECEIVER_INTEGRATION_ID=????
export WEBHOOK_RECEIVER_PROCESS_EVENT_SCRIPT=customers/demo/integrations/jira_process_event.rb

# custom settings
export WEBHOOK_RECEIVER_BRPM_HOST=localhost
export WEBHOOK_RECEIVER_BRPM_PORT=8088
export WEBHOOK_RECEIVER_BRPM_TOKEN=????
export WEBHOOK_RECEIVER_JIRA_RELEASE_FIELD_ID=????

VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")

. $BRPM_HOME/bin/setenv.sh

jruby $BRPM_HOME/releases/$VERSION/RPM/lib/script_support/git_repos/brpm_content/infrastructure/integrations/webhook_receiver.rb
