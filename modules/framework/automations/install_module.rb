BrpmAuto.params["name"]
BrpmAuto.params["version"]

version_flag = ""
if BrpmAuto.params["version"] and ! BrpmAuto.params["version"].empty?
  version_flag = " -v #{BrpmAuto.params["version"]}"
end

result = BrpmAuto.execute_shell("export GEM_HOME=${BRPM_CONTENT_HOME:-$BRPM_HOME/modules} && gem install #{BrpmAuto.params["name"]} #{version_flag}")
BrpmAuto.log result["stdout"] if result["stdout"] and ! result["stdout"].empty?
unless result["status"] == 0
  raise result["stderr"]
end