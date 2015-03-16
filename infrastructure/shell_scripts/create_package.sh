#!/bin/bash
. /opt/bmc/RLM/bin/setenv.sh

jruby <<-EORUBY
require "v2/bootstrap"

require "brpm/lib/brpm_rest_api"
set_brpm_rest_api_url("http://$BRPM_HOST:$BRPM_PORT/brpm")
set_brpm_rest_api_token("$BRPM_TOKEN")

params = {}
params["application"] = "$APPLICATION"
params["component"] = "$COMPONENT"
params["component_version"] = "$COMPONENT_VERSION"

params["SS_integration_dns"] = "$SS_INTEGRATION_DNS"
params["SS_integration_username"] = "$SS_INTEGRATION_USERNAME"
params["SS_integration_password"] = "$SS_INTEGRATION_PASSWORD"
params["SS_integration_details"] = {}
params["SS_integration_details"]["role"] = "$SS_INTEGRATION_DETAILS_ROLE"

params["log_file"] = "$LOG_FILE"
params["automation_script_dir"] = "."

execute_script_from_module("bladelgic", "create_package", params)
EORUBY

