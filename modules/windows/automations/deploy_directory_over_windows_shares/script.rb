require "windows/lib/samba"
require 'fileutils'

def execute_script(params)
  raise "Repo directory is not provided" if params["repo_directory"].empty?
  repo_directory = sub_tokens(params, params["repo_directory"])

  raise "Repo directory is not provided" if params["repo_directory"].empty?
  target_server_directory = sub_tokens(params, params["target_server_directory"])

  temp_directory = "#{params["SS_output_dir"]}/package"

  FileUtils.rm_rf(temp_directory) if File.exists?(temp_directory)
  Dir.mkdir(temp_directory)

  if params["SS_integration_dns"].nil?
    repo_server_name = params["repo_server_name"]
    repo_server_share = params["repo_server_share"]
    repo_server_username = params["repo_server_username"]
    repo_server_password = params["repo_server_password"]
  else
    repo_server_name  = params["SS_integration_dns"]
    repo_server_share = params["SS_integration_details"]["share"]
    repo_server_username = params["SS_integration_username"]
    repo_server_password = decrypt_string_with_prefix(params["SS_integration_password_enc"]) unless params["SS_integration_password_enc"].empty?
  end

  Logger.log("Getting directory #{repo_directory} from the repo...")
  smbclient_get_directory(
      repo_server_name,
      repo_server_share,
      repo_server_username,
      repo_server_password,
      repo_directory,
      temp_directory
  )

  unless params["param_substitution_file_list"].empty?
    Logger.log("Substituting params in the indicated files...")
    file_paths = params["param_substitution_file_list"].split(";")
    file_paths.each do|file_path|
      file_absolute_path = "#{temp_directory}/#{file_path}"
      unless File.exists?(file_absolute_path)
        Logger.log("File #{file_absolute_path} doesn't exist, continuing...")
        next
      end

      Logger.log("Substituting params in file #{file_path}...")
      file_content = File.read(file_absolute_path)
      substituted_file_content = sub_tokens(params,file_content)
      File.open(file_absolute_path, "w") {|file| file.puts substituted_file_content}
    end
  end

  unless params["exclude_file_list"].empty?
    Logger.log("Excluding the indicated files...")
    file_paths = params["exclude_file_list"].split(";")
    file_paths.each do|file_path|
      file_absolute_path = "#{temp_directory}/#{file_path}"
      if File.exists?(file_absolute_path)
        Logger.log("Deleting file #{file_path}...")
        file_content = File.delete(file_absolute_path)
      else
        Logger.log("File #{file_absolute_path} doesn't exist, continuing...")
        next
      end
    end
  end

  Logger.log("Getting the list of target servers...")
  servers = get_server_list(params)
  Logger.log("Found #{servers.count} servers.")

  servers.each do |server|
    Logger.log("Putting directory #{repo_directory} onto server #{server[0]} (//#{server[1]["ip_address"]}/#{server[1]["deploy_share_name"]})...")
    smbclient_put_directory(
        server[1]["ip_address"],
        server[1]["deploy_share_name"],
        server[1]["deploy_share_username"],
        server[1]["deploy_share_password"],
        target_server_directory,
        temp_directory
    )
  end

  Logger.log("Cleaning up the directory locally...")
  FileUtils.rm_rf(temp_directory)
end