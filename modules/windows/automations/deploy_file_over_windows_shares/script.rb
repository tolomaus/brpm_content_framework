require "windows/lib/samba"

def execute_script(params)
  repo_directory = BrpmAuto.substitute_tokens(params["repo_directory"])
  file_name = BrpmAuto.substitute_tokens(params["file_name"])
  target_server_directory = BrpmAuto.substitute_tokens(params["target_server_directory"])

  BrpmAuto.log("Getting package #{repo_directory}/#{file_name} from the repo...")
  smbclient_get_file(
      params["repo_server_name"],
      params["repo_server_share"],
      params["repo_server_username"],
      params["repo_server_password"],
      repo_directory,
      file_name,
      params["SS_output_dir"]
  )

  servers = get_server_list(params)

  servers.each do |server|
    BrpmAuto.log("Putting package #{repo_directory}/#{file_name} to server #{server[0]}...")
    smbclient_put_file(
        server[1]["ip_address"],
        server[1]["deploy_share_name"],
        server[1]["deploy_share_username"],
        server[1]["deploy_share_password"],
        target_server_directory,
        file_name,
        params["SS_output_dir"]
    )
  end
end