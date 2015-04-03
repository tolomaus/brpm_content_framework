#!/bin/bash
. /opt/bmc/RLM/bin/setenv.sh

jruby <<-EORUBY
require "bootstrap"

require "brpm/lib/brpm_rest_api"
set_brpm_rest_api_url("http://$BRPM_HOST:$BRPM_PORT/brpm")
set_brpm_rest_api_token("$BRPM_TOKEN")

params = {}
params["log_file"] = "$LOG_FILE"
params["automation_script_dir"] = "."

params["application_name"] = "$APPLICATION_NAME"
params["application_version"] = "$APPLICATION_VERSION"
params["release_request_template_name"] = "$RELEASE_REQUEST_TEMPLATE_NAME"
params["release_plan_template_name"] = "$RELEASE_PLAN_TEMPLATE_NAME"

execute_script_from_module("brpm", "create_release", params)
EORUBY

