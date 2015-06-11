params = BrpmAuto.params

BrpmAuto.log "Triggering a new build..."
TeamCityRestClient.new.trigger_build(params["application"], params["component"])
