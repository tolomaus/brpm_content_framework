rem mandatory settings
set EVENT_HANDLER_MESSAGING_PORT=5445
set EVENT_HANDLER_MESSAGING_USERNAME=msguser
set EVENT_HANDLER_MESSAGING_PASSWORD=
set EVENT_HANDLER_LOG_FILE=c:/tmp/event_handler.log
set EVENT_HANDLER_PROCESS_EVENT_SCRIPT=customers/demo/integrations/brpm/process_event_handler_event.rb

# custom settings
set EVENT_HANDLER_BRPM_PORT=29418
set EVENT_HANDLER_BRPM_TOKEN=

set EVENT_HANDLER_JIRA_URL=http://localhost:9090
set EVENT_HANDLER_JIRA_USERNAME=brpm
set EVENT_HANDLER_JIRA_PASSWORD=

jruby /opt/bmc/RLM/releases/4.6.00/RPM/lib/script_support/git_repos/brpm_dev_automation_scripts/integrations/event_handler.rb