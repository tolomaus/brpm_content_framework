#!/bin/bash

# ASSUMPTION: this script should be executed from the root direcory of the framework

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the installation."
    exit 1
fi

. $BRPM_HOME/bin/setenv.sh

jruby <<-EORUBY
require "modules/framework/brpm_script_executor"

params = {}
params["application"] = "$APPLICATION"
params["component"] = "$COMPONENT"
params["component_version"] = "$COMPONENT_VERSION"

params["brpm_url"] = "http://$BRPM_HOST:$BRPM_PORT/brpm"
params["brpm_api_token"] = "$BRPM_TOKEN"

params["SS_integration_dns"] = "$SS_INTEGRATION_DNS"
params["SS_integration_username"] = "$SS_INTEGRATION_USERNAME"
params["SS_integration_password"] = "$SS_INTEGRATION_PASSWORD"
params["SS_integration_details"] = {}
params["SS_integration_details"]["role"] = "$SS_INTEGRATION_DETAILS_ROLE"

params["log_file"] = "$LOG_FILE"
params["also_log_to_console"] = "true"

BrpmScriptExecutor.execute_automation_script("bladelogic", "create_package", params)
EORUBY

