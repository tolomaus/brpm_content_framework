rem mandatory settings
set WEBHOOK_RECEIVER_PORT=8089
set WEBHOOK_RECEIVER_MOUNT_POINT=webhooks
set WEBHOOK_RECEIVER_LOG_FILE=c:/tmp/webhook_receiver.log
set WEBHOOK_RECEIVER_INTEGRATION_ID=???
set WEBHOOK_RECEIVER_PROCESS_EVENT_SCRIPT=integrations/jira/process_webhook_event.rb

rem custom settings
set WEBHOOK_RECEIVER_BRPM_HOST=localhost
set WEBHOOK_RECEIVER_BRPM_PORT=8080
set WEBHOOK_RECEIVER_BRPM_TOKEN=???
set WEBHOOK_RECEIVER_JIRA_RELEASE_FIELD_ID=???

webhook_receiver

