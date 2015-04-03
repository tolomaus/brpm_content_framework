#!/bin/bash

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the script."
    exit 1
fi

# mandatory settings
export EVENT_HANDLER_BRPM_HOST=localhost

export EVENT_HANDLER_MESSAGING_PORT=5445
export EVENT_HANDLER_MESSAGING_USERNAME=msguser
export EVENT_HANDLER_MESSAGING_PASSWORD=????
export EVENT_HANDLER_LOG_FILE=/tmp/event_handler.log
export EVENT_HANDLER_PROCESS_EVENT_SCRIPT=customers/demo/integrations/event_handler_process_event.rb

# custom settings
export EVENT_HANDLER_BRPM_PORT=8088
export EVENT_HANDLER_BRPM_TOKEN=????

export EVENT_HANDLER_JIRA_URL=http://jira-server:9090
export EVENT_HANDLER_JIRA_USERNAME=????
export EVENT_HANDLER_JIRA_PASSWORD=????
export EVENT_HANDLER_JIRA_RELEASE_FIELD_ID=????

VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")

. $BRPM_HOME/bin/setenv.sh

jruby $BRPM_HOME/releases/$VERSION/RPM/lib/script_support/git_repos/brpm_content/infrastructure/integrations/event_handler.rb