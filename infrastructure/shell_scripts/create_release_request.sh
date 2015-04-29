#!/bin/bash
. /opt/bmc/RLM/bin/setenv.sh

jruby <<-EORUBY
require "modules/framework/brpm_automation"

params = {}
params["application_name"] = "$APPLICATION_NAME"
params["application_version"] = "$APPLICATION_VERSION"
params["release_request_template_name"] = "$RELEASE_REQUEST_TEMPLATE_NAME"
params["release_plan_template_name"] = "$RELEASE_PLAN_TEMPLATE_NAME"

params["brpm_url"] = "http://$BRPM_HOST:$BRPM_PORT/brpm"
params["brpm_api_token"] = "$BRPM_TOKEN"

params["log_file"] = "$LOG_FILE"

BrpmAuto.execute_script_from_module("brpm", "create_release_request", params)
EORUBY

