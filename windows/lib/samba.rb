def smbclient_get_file(smb_server_name, smb_server_share, smb_server_username, smb_server_password, smb_server_directory, file_name, target_directory)
  exec_command("smbclient '//#{smb_server_name}/#{smb_server_share}' #{smbclient_escape(smb_server_password)} -c 'lcd #{target_directory}; cd #{smb_server_directory}; get #{file_name}' -U #{smbclient_escape(smb_server_username)}", smbclient_escape(smb_server_password))
end

def smbclient_put_file(smb_server_name, smb_server_share, smb_server_username, smb_server_password, smb_server_directory, file_name, source_directory)
  exec_command("smbclient '//#{smb_server_name}/#{smb_server_share}' #{smbclient_escape(smb_server_password)} -c 'lcd #{source_directory}; cd #{smb_server_directory}; put #{file_name}' -U #{smbclient_escape(smb_server_username)}", smbclient_escape(smb_server_password))
end

def smbclient_get_directory(smb_server_name, smb_server_share, smb_server_username, smb_server_password, smb_server_directory, target_directory)
  exec_command("smbclient '//#{smb_server_name}/#{smb_server_share}' #{smbclient_escape(smb_server_password)} -c 'lcd #{target_directory}; cd #{smb_server_directory}; recurse; prompt; mget *' -U #{smbclient_escape(smb_server_username)}", smbclient_escape(smb_server_password))
end

def smbclient_put_directory(smb_server_name, smb_server_share, smb_server_username, smb_server_password, smb_server_directory, source_directory)
  exec_command("smbclient '//#{smb_server_name}/#{smb_server_share}' #{smbclient_escape(smb_server_password)} -c 'lcd #{source_directory}; cd #{smb_server_directory}; recurse; prompt; mput *' -U #{smbclient_escape(smb_server_username)}", smbclient_escape(smb_server_password))
end

def smbclient_get_directory_via_tar(smb_server_name, smb_server_share, smb_server_username, smb_server_password, smb_server_directory, tar_file_name)
  exec_command("smbclient '//#{smb_server_name}/#{smb_server_share}' #{smbclient_escape(smb_server_password)} -U #{smbclient_escape(smb_server_username)} -Tc #{tar_file_name} #{smb_server_directory}", smbclient_escape(smb_server_password))
end

def smbclient_restore_directory_via_tar(smb_server_name, smb_server_share, smb_server_username, smb_server_password, tar_file_name)
  exec_command("smbclient '//#{smb_server_name}/#{smb_server_share}' #{smbclient_escape(smb_server_password)} -U #{smbclient_escape(smb_server_username)} -Tx #{tar_file_name}", smbclient_escape(smb_server_password))
end

def smbclient_escape(string)
  return string if string.nil? or string.empty?

  string.gsub('\\', '\\\\\\\\').gsub('$', '\$')
end