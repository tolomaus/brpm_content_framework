#!/bin/bash
. /opt/bmc/RLM/bin/setenv.sh

jruby <<-EORUBY
require "modules/framework/brpm_automation"

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

BrpmAuto.execute_script_from_module("bladelogic", "create_package", params)
EORUBY

