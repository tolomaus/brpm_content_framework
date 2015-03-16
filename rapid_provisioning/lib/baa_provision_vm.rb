require 'json'
require 'rest-client'
require 'uri'
require 'savon'
require 'base64'
require 'yaml'
require 'lib/script_support/baa_utilities'

def provision_vm(params)
  baa_username = params["baa_username"]
  baa_password = decrypt_string_with_prefix(params["baa_password_enc"])
  baa_role = params["baa_role"]
  baa_base_url = params["baa_base_url"]
  
  update_props_job = "/BRPM/Provisioning/Update properties"
  update_ipres_job = "/BRPM/Provisioning/Update IP resolution"

  Logger.log "Logging in to BladeLogic ..."
  session_id = BaaUtilities.baa_soap_login(baa_base_url, baa_username, baa_password)
  raise "Could not login to BAA Cli Tunnel Service" if session_id.nil?
  Logger.log "Successfully logged on."

  Logger.log "Assuming role in to BladeLogic ..."
  BaaUtilities.baa_soap_assume_role(baa_base_url, baa_role, session_id)
  Logger.log "Successfully assumed role."

  # Check that we've the needed data
  hostname = sub_tokens(params, params["HostName"])
  ipaddress = sub_tokens(params, params["IPaddress"])
  subnetmask = sub_tokens(params, params["SubnetMask"])
  gateway = sub_tokens(params, params["Gateway"])
  dns = sub_tokens(params, params["DNS"])
  domain = sub_tokens(params, params["Domain"])
  
  raise "Error: You need to select an Hypervisor" if params["Hypervisor"] == "Select"
  raise "Error: You need to select a target location" if params["Location"].empty?
  raise "Error: You need to provide a host name" if hostname.empty?
  raise "Error: You need to complete IPadresse and Subnet Mask when DHCP iset to No" if params["DHCP"] == "No" && ( ipaddress.empty? || subnetmask.empty?)
  
  # Initialize variables
  vgpgroup = "/BRPM/Provisioning"
  jobgroup = "/BRPM/Provisioning"
  jobgroupid = BaaUtilities.baa_soap_execute_cli_command_by_param_list(baa_base_url, session_id,"JobGroup", "groupNameToId", [jobgroup])[:return_value]
  vgpname = params["VMTemplate"].split("|")[0]
  jobname = hostname + "-" + vgpname + "-" + Time.now.strftime("%Y%m%d-%H:%M:%S")
  datastore = params["Location"].split("|")[0]
  vgpdest = params["Location"].split("|")[2]
  vgpid = BaaUtilities.baa_soap_execute_cli_command_by_param_list(baa_base_url, session_id, "Virtualization", "getVirtualGuestPackageIdByGroupAndName", [vgpgroup,vgpname])[:return_value]
  vgpdef = BaaUtilities.baa_soap_execute_cli_command_by_param_list(baa_base_url, session_id, "Virtualization", "getVirtualGuestPackage", [vgpid])[:return_value]
  vgpid = BaaUtilities.baa_soap_execute_cli_command_by_param_list(baa_base_url, session_id, "Virtualization", "getVirtualGuestPackageIdByGroupAndName", [vgpgroup,vgpname])[:return_value]
  
  ########################################################################
  ###building xml definition of the virtual guest package provisioning job
  ########################################################################
  vgpjdef = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
  <VirtualGuestJobConfiguration>
      <VirtualGuestPackage>
          <VGPackageID>#{vgpid}</VGPackageID>
          <VirtualGuestName>#{hostname}</VirtualGuestName>
  " + vgpdef[/<PlatformInfo>.*PlatformInfo>/m] + "
      </VirtualGuestPackage>
      <VirtualGuestJob>
    <JobName>#{jobname}</JobName>
    <JobFolderID>#{jobgroupid}</JobFolderID>
          <VirtualGuestDestination>#{vgpdest}</VirtualGuestDestination>
          <ExecuteNow>false</ExecuteNow>
      </VirtualGuestJob>
  </VirtualGuestJobConfiguration>
  "
  # Putting datastore location
  vgpjdef = vgpjdef.gsub(/<Datastore>[^<]*/m, "<Datastore>#{datastore}")
  vgpjdef = vgpjdef.gsub(/<VMXDatastore>[^<]*/m, "<VMXDatastore>#{datastore}")
  
  # Setting the right network parameters
  if params["DHCP"] == "Yes"
    networkdef = "<GuestNetworkConfiguration>
          <AutoIPAddress>true</AutoIPAddress>
          <AutoDNS>true</AutoDNS>
        </GuestNetworkConfiguration>"
  else
    networkdef = "<GuestNetworkConfiguration>
          <IPAddress>#{ipaddress}</IPAddress>
          <SubnetMask>#{subnetmask}</SubnetMask>
          <DefaultGateway>#{gateway}</DefaultGateway>
          <PrimaryDNS>#{dns}</PrimaryDNS>
        </GuestNetworkConfiguration>"
  end
  vgpjdef = vgpjdef.gsub(/<GuestNetworkConfiguration>.*<\/GuestNetworkConfiguration>/m, networkdef)
  
  # Setting hostname and domaine
  vgpjdef = vgpjdef.gsub(/<HostName>[^<]*/m, "<HostName>#{hostname}")
  vgpjdef = vgpjdef.gsub(/<Domain>[^<]/m, "<Domain>#{domain}")
  
  ########################################################################
  ###Create virtual guest package job and run it
  ########################################################################
  qualfname = params["brpm_base_url"].split(":")[1] + "/notneeded"
  jobdbkey = BaaUtilities.baa_soap_execute_cli_command_using_attachments(baa_base_url, session_id, "Virtualization", "createVirtualGuest", [qualfname], vgpjdef)[:return_value].split(" ").last
  joburi = BaaUtilities.baa_soap_db_key_to_rest_uri(baa_base_url, session_id, jobdbkey)
  h = BaaUtilities.execute_job(baa_base_url, baa_username, baa_password, baa_role, joburi)
  raise "Could run specified job, did not get a valid response from server" if h.nil?
  
  # Manage Job result output
  execution_status = "OK"
  execution_status = "VM provisioning error" if (h["had_errors"] == "true")
  
  ########################################################################
  ###Run IP resolution update Job if exist
  ########################################################################
  jobdbkey = BaaUtilities.get_job_dbkey_from_job_qualified_name(baa_base_url, baa_username, baa_password, baa_role, update_ipres_job) rescue nil
  if (execution_status == "OK") && (jobdbkey != nil) && (ipaddress != "")
    job_group = File.dirname(update_ipres_job)
    job_name = hostname + "-UpdateIPresolution-" + Time.now.strftime("%Y%m%d-%H:%M:%S")
    session_id = BaaUtilities.baa_soap_login(baa_base_url, baa_username, baa_password)
    raise "Could not login to BAA Cli Tunnel Service" if session_id.nil?
    BaaUtilities.baa_soap_assume_role(baa_base_url, baa_role, session_id)
    jobdbkey = BaaUtilities.baa_soap_execute_cli_command_by_param_list(baa_base_url, session_id,"Job","copyJob",[jobdbkey,job_group,job_name])[:return_value]
    jobdbkey = BaaUtilities.baa_set_nsh_script_property_value_in_job(baa_base_url, session_id, job_group, job_name, 0, params["IPResolution"])
    jobdbkey = BaaUtilities.baa_set_nsh_script_property_value_in_job(baa_base_url, session_id, job_group, job_name, 1, ipaddress)
    jobdbkey = BaaUtilities.baa_set_nsh_script_property_value_in_job(baa_base_url, session_id, job_group, job_name, 2, hostname)
    joburi = BaaUtilities.get_job_uri_from_job_qualified_name(baa_base_url, baa_username, baa_password, baa_role, "#{job_group}/#{job_name}")
    h1 = BaaUtilities.execute_job(baa_base_url, baa_username, baa_password, baa_role, joburi)
    execution_status = "Update IP Resolution error" if (h1["had_errors"] == "true")
  end
  
  ########################################################################
  ###Run Update properties Job if exist
  ########################################################################
  jobdbkey = BaaUtilities.get_job_dbkey_from_job_qualified_name(baa_base_url, baa_username, baa_password, baa_role, update_props_job) rescue nil
  if (execution_status == "OK") && (jobdbkey != nil)
    job_group = File.dirname(update_props_job)
    job_name = hostname + "-UpdateProperties-" + Time.now.strftime("%Y%m%d-%H:%M:%S")
    jobdbkey = BaaUtilities.baa_soap_execute_cli_command_by_param_list(baa_base_url, session_id,"Job","copyJob",[jobdbkey,job_group,job_name])[:return_value]
    joburi = BaaUtilities.get_job_uri_from_job_qualified_name(baa_base_url, baa_username, baa_password, baa_role, "#{job_group}/#{job_name}")
    servuri = BaaUtilities.get_server_uri_from_name(baa_base_url, baa_username, baa_password, baa_role,hostname)
    agtstatus = "down"
    nbtry = 0
    until (nbtry > 16) || (agtstatus == "agent is alive") do
      sleep(15)
      h1 = BaaUtilities.execute_job_against_servers(baa_base_url, baa_username, baa_password, baa_role, joburi, [servuri])
      agtstatus = BaaUtilities.get_property_value_from_uri(baa_base_url, baa_username, baa_password, baa_role, servuri, "AGENT_STATUS")
      nbtry += 1
    end
    raise "Can not reach BladeLogic Agent" if nbtry > 16
    execution_status = "Update props error" if (h1["had_errors"] == "true")
  end
end


