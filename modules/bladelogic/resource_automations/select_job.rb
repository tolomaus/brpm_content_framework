def execute_script(params, parent_id, offset, max_records)
  root_group_name = "/#{params["application"].downcase}/public"

  BrpmAuto.log("Logging on to Bladelogic instance #{BsaSoapClient.get_url} with user #{BsaSoapClient.get_username} and role #{BsaSoapClient.get_role}...")
  session_id = BsaSoapClient.login

  if parent_id.blank?
    BrpmAuto.log("Retrieving all the groups from group #{root_group_name}...")
    groups = JobGroup.find_all_groups_by_parent_group_name(session_id, {:job_group => root_group_name})

    groups = groups.to_s.split(' ').sort()

    results = []
    groups.each do |group|
      results << { :title => group, :key => group, :isFolder => true, :hasChild => true, :hideCheckbox => true }
    end
  else
    job_type = parent_id
    group_name = "#{root_group_name}/#{job_type}"

    BrpmAuto.log("Retrieving all the objects from group #{group_name}...")
    jobs = Job.list_all_by_group(session_id, {:group_name => group_name})

    jobs = jobs.to_s.split(' ').sort

    results = []
    jobs.each do |job|
      results << { :title => job, :key => "#{job_type}|#{job}", :isFolder => false }
    end
  end

  results
end