rem mandatory settings
set WEBHOOK_RECEIVER_PORT=8089
set WEBHOOK_RECEIVER_MOUNT_POINT=webhooks
set WEBHOOK_RECEIVER_LOG_FILE=c:/tmp/webhook_receiver.log
set WEBHOOK_RECEIVER_INTEGRATION_ID=4
set WEBHOOK_RECEIVER_PROCESS_EVENT_SCRIPT=customers/demo/integrations/jira_process_event.rb

rem custom settings
set WEBHOOK_RECEIVER_BRPM_PORT=8080
set WEBHOOK_RECEIVER_BRPM_TOKEN=
set WEBHOOK_RECEIVER_JIRA_RELEASE_FIELD_ID=10000

jruby "C:\Program Files\BMC Software\RLM\releases\4.6.00\RPM\lib\script_support\git_repos\brpm_dev_automation_scripts\integrations\webhook_receiver.rb"

