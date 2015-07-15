BrpmAuto.params["name"]
BrpmAuto.params["version"]

BrpmAuto.execute_shell("export GEM_HOME=${BRPM_CONTENT_HOME:-$BRPM_HOME/modules} && gem install #{BrpmAuto.params["name"]} #{BrpmAuto.params["version"] ? " -v #{BrpmAuto.params["version"]}" : ""}")