require "windows/lib/samba"

def execute_script(params)
  repo_directory = sub_tokens(params, params["repo_directory"])
  file_name = sub_tokens(params, params["file_name"])
  target_server_directory = sub_tokens(params, params["target_server_directory"])

  Logger.log("Getting package #{repo_directory}/#{file_name} from the repo...")
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
    Logger.log("Putting package #{repo_directory}/#{file_name} to server #{server[0]}...")
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