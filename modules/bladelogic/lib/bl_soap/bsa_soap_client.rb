class BsaSoapClient < BsaSoapBase
  def initialize(integration_settings = BrpmAuto.integration_settings)
    @url = integration_settings.dns
    @session_id = Login.new(integration_settings).login
  end

  def blpackage
    @blpackage ||= BlPackage.new(@url, @session_id)
  end

  def depot_group
    @depot_group ||= DepotGroup.new(@url, @session_id)
  end

  def job
    @job ||= Job.new(@url, @session_id)
  end

  def job_run
    @job_run ||= JobRun.new(@url, @session_id)
  end

  def deploy_job
    @deploy_job ||= DeployJob.new(@url, @session_id)
  end

  def job_group
    @job_group ||= JobGroup.new(@url, @session_id)
  end

  def depot_group
    @depot_group ||= DepotGroup.new(@url, @session_id)
  end

  def utility
    @utility ||= Utility.new(@url, @session_id)
  end
end