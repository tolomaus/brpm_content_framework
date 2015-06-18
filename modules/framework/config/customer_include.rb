# This file should be located in BRPM_HOME/config
# See the README for more information on how to use this file

def get_customer_include_params
  params = {}
  # Hostname so nsh paths can be constructed from local paths
  params["BAA_RPM_HOSTNAME"] = "localhost"
  # set your own automation token
  params["Token"] = "???"
  # Hostname so nsh paths can be constructed from local paths
  params["BAA_RPM_HOSTNAME"] = "localhost"
  # Change this to set BAA base path
  params["BAA_BASE_PATH"] = "/opt/bmc/bladelogic"
  # This is the root path for use in BAA/BSA
  params["BAA_BASE_GROUP"] = "BRPM"
  # The location and name of the standard NSH script for script execution
  params["BAA_FRAMEWORK_NSH_SCRIPT"] = "/BRPM/NSHScripts/FrameworkScriptExecute"
  # Place your own global constants
  params["DATA_CENTER_NAMES"] = ["HOU", "LEX", "PUNE"]

  params
end

def my_custom_method(a, b)
  a + b
end
