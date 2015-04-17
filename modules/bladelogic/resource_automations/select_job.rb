def execute_resource_automation_script(params, parent_id, offset, max_records)
  BsaSoap.disable_verbose_logging

  bsa_base_url = BrpmAuto.integration_server_settings.dns
  bsa_username = BrpmAuto.integration_server_settings.username
  bsa_password = BrpmAuto.integration_server_settings.password
  bsa_role = BrpmAuto.integration_server_settings.details["role"]

  root_group_name = "/#{params["application"].downcase}/public"

  Logger.log("Logging on to Bladelogic instance #{bsa_base_url} with user #{bsa_username} and role #{bsa_role}...")
  session_id = BsaSoap.login_with_role(bsa_base_url, bsa_username, bsa_password, bsa_role)

  if parent_id.blank?
    Logger.log("Retrieving all the groups from group #{root_group_name}...")
    groups = JobGroup.find_all_groups_by_parent_group_name(bsa_base_url, session_id, {:job_group => root_group_name})

    groups = groups.to_s.split(' ').sort()

    results = []
    groups.each do |group|
      results << { :title => group, :key => group, :isFolder => true, :hasChild => true, :hideCheckbox => true }
    end
  else
    job_type = parent_id
    group_name = "#{root_group_name}/#{job_type}"

    Logger.log("Retrieving all the objects from group #{group_name}...")
    jobs = Job.list_all_by_group(bsa_base_url, session_id, {:group_name => group_name})

    jobs = jobs.to_s.split(' ').sort

    results = []
    jobs.each do |job|
      results << { :title => job, :key => "#{job_type}|#{job}", :isFolder => false }
    end
  end

  results
end