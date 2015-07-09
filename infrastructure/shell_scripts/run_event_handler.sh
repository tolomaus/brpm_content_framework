#!/bin/bash
# mandatory settings
export EVENT_HANDLER_BRPM_HOST=localhost

export EVENT_HANDLER_MESSAGING_PORT=5445
export EVENT_HANDLER_MESSAGING_USERNAME=msguser
export EVENT_HANDLER_MESSAGING_PASSWORD=????
export EVENT_HANDLER_LOG_FILE=/tmp/event_handler.log
export EVENT_HANDLER_PROCESS_EVENT_SCRIPT=integrations/brpm/process_event_handler_event.rb

# custom settings
export EVENT_HANDLER_BRPM_PORT=8088
export EVENT_HANDLER_BRPM_TOKEN=????

export EVENT_HANDLER_JIRA_URL=http://jira-server:9090
export EVENT_HANDLER_JIRA_USERNAME=????
export EVENT_HANDLER_JIRA_PASSWORD=????
export EVENT_HANDLER_JIRA_RELEASE_FIELD_ID=????

event_handler