# dispatch_base.rb
#  Module for action dispatch common methods
require 'digest/md5'

DEFAULT_PARAMS_FILTER = "ENV_" if !defined?(DEFAULT_PARAMS_FILTER)
STANDARD_PROPERTIES = ["SS_application", "SS_component", "SS_environment", "SS_component_version", "SS_request_number"]
OS_PLATFORMS = {
  "win" => {"name" => "Windows", "tmp_dir" => "/C/Windows/temp"},
  "nix" => {"name" => "Unix", "tmp_dir" => "/tmp"},
  "nux" => {"name" => "Linux", "tmp_dir" => "/tmp"}}


class DispatchBase
  # Initialize the class
  #
  # ==== Attributes
  #
  # * +options+ - hash of options to use, send "output_file" to point to the logging file
  # * +test_mode+ - true/false to simulate commands instead of running them
  #
  def initialize(options = {}, compat_options = {})
    self.extend Utilities
    if options.has_key?("SS_output_dir")
      BrpmAuto.log "Load for this class has changed, no longer necessary to send params as 1st argument"
      options = compat_options 
    end
    @verbose = get_option(options, "verbose", false)
    @output_dir = BrpmAuto.params.output_dir
  end

  # Builds a hash of properties to transfer to target
  # 
  # ==== Attributes
  #
  # * +keyword_filter+ - filter for params (param selected if filter included in key)
  # * +strip_filter+ - removes filter text from resulting key
  # ==== Returns
  #
  # hash of properties to transfer
  #
  def get_transfer_properties(keyword_filter = DEFAULT_PARAMS_FILTER, strip_filter = true)
    result = {}
    STANDARD_PROPERTIES.each{|prop| result[prop.gsub("SS_","RPM_")] = BrpmAuto.params[prop] }
    BrpmAuto.params.each{|k,v| result[strip_filter ? k.gsub(keyword_filter,"") : k] = v if k.include?(keyword_filter) }
    result
  end

  # Add BRPD-like params to transfer_properties
  # 
  # ==== Attributes
  #
  # * +props+ - the existing transfer properties hash
  # * +payload_path+ - the path for any previously delivered content
  # * +target_dir+ - the delivery directory on the target
  # ==== Returns
  #
  # nothing - modifies passed property hash
  #
  def brpd_compatibility(props, payload_path = nil, servers = nil)
     props["VL_CONTENT_PATH"] = payload_path if payload_path
     props["VL_CONTENT_NAME"] = File.basename(payload_path)  if payload_path
     props["VL_CHANNEL_ROOT"] = props["RPM_CHANNEL_ROOT"]
     props["VL_DISPATCH_TARGET_HOST"] = servers.nil? ? get_server_list.keys[0] : servers.first[0]
  end

  # Add server properties to transfer properties
  # 
  # ==== Attributes
  #
  # * +props+ - the existing transfer properties hash
  # * +servers+ - hash of server properties
  # * +os_platform+ - os platform
  # ==== Returns
  #
  # nothing - modifies passed property hash
  #
  def add_channel_properties(props, servers, os_platform = "win")
     s_props = servers.first[1]
     base_dir = s_props["CHANNEL_ROOT"] if s_props.has_key?("CHANNEL_ROOT")
     base_dir ||= s_props["base_dir"] if s_props.has_key?("base_dir")
     base_dir ||= OS_PLATFORMS[os_platform]["tmp_dir"]
     props["RPM_CHANNEL_ROOT"] = base_dir
  end
  
  # Removes carriage returns for unix compatibility
  # Opens passed script path, modifies and saves file
  # ==== Attributes
  #
  # * +os_platform+ - os platform
  # * +script_file+ - path to script to modify
  # * +contents+ - optional - if passed will replace the content in script_file
  # ==== Returns
  #
  # path to modified script
  #
  def clean_line_breaks(os_platform, script_file, contents = nil)
    return if os_platform =~ /win/
    contents = File.open(script_file).read if contents.nil?
    fil = File.open(script_file,"w+")
    fil.puts contents.gsub("\r", "")
    fil.flush
    fil.close
    script_file
  end
  
  # Creates a temp file in output dir
  # returns path to temp file
  # ==== Attributes
  #
  # * +content+ - content for file
  # * +options+ - hash of options, includes ext to force the file extension e.g. {"ext" => ".sql"}
  # ==== Returns
  #
  # path to file
  #
  def make_temp_file(content, platform = "linux", options = {})
    ext = get_option(options, "ext")
    if ext == ""
      ext = platform.downcase == "linux" ? ".sh" : ".bat"
    end
    file_path = File.join(BrpmAuto.params["SS_output_dir"],"shell_#{precision_timestamp}#{ext}")
    fil = File.open(file_path, "w+")
    fil.puts content
    fil.flush
    fil.close
    file_path
  end

  # Builds the wrapper script for the target
  # sets environment variables and call to run target script
  # follows platform directives or shebang information
  #
  # ==== Attributes
  #
  # * +os_platform+ - os platform
  # * +shebang+ - hash of processed shebang
  # * +properties+ - hash of properties to become environment variables
  # * +options+ - hash of optionss, includes script_target - what the wrapper will call 
  # ==== Returns
  #
  # path to wrapper script
  #
  def build_wrapper_script(os_platform, shebang, properties, options = {})
    msg = "Environment variables from BRPM"
    wrapper = "srun_wrapper_#{precision_timestamp}"
    alt_target = get_option(options,"script_target")
    cmd = shebang["cmd"]
    target = alt_target == "" ? File.basename(get_param("SS_script_file")) : alt_target
    cmd = cmd.gsub("%%", target) if shebang["cmd"].end_with?("%%")
    cmd = "#{cmd} #{target}" unless shebang["cmd"].end_with?("%%")
    if os_platform =~ /win/
      properties["RPM_CHANNEL_ROOT"] = dos_path(properties["RPM_CHANNEL_ROOT"])
      properties["VL_CHANNEL_ROOT"] = properties["RPM_CHANNEL_ROOT"]
      wrapper = "#{wrapper}.bat"
      script = "@echo off\r\necho |hostname > junk.txt\r\nset /p HOST=<junk.txt\r\necho y|del junk.txt\r\n"
      script += "echo ============== HOSTNAME: %HOST% ==============\r\n"
      script += "echo #{msg} \r\n"
      properties.each{|k,v| script += "set #{k}=#{v}\r\n" }
      script += "echo Execute the file\r\n"
      script += "cd %RPM_CHANNEL_ROOT%\r\n"
      script += "#{cmd}\r\n"
      script += "echo EXIT_CODE: %errorlevel%\r\n"
      script += "timeout /t <5> /nobreak\r\n"
      script += "echo y|del #{target}\r\n"
    else
      wrapper = "#{wrapper}.sh"
      script = "echo \"============== HOSTNAME: `hostname` ==============\"\n"
      script += "echo #{msg} \n"
      properties.each{|k,v| script += "export #{k}=\"#{v}\"\n" }
      script += "echo Execute the file\n"
      script += "cd $RPM_CHANNEL_ROOT\n"
      script += "#{cmd}\n"
      script += "echo EXIT_CODE: $?\n"
      script +=  "sleep 2\nrm -f #{target}"    
    end
    fil = File.open(File.join(@output_dir, wrapper),"w+")
    fil.puts script
    fil.flush
    fil.close
    File.join(@output_dir, wrapper)
  end

  # Builds the wrapper script for a single command
  #
  # ==== Attributes
  #
  # * +command+ - command to execute e.g. unzip
  # * +os_platform+ - os platform
  # * +source_path+ - path to source file (local)
  # * +target_path+ - destination path on target server
  # ==== Returns
  #
  # path to wrapper script
  #
  def create_command_wrapper(command, os_platform, source_path, target_path)
    msg = "Environment variables from BRPM"
    wrapper = "srun_wrapper_#{precision_timestamp}"
    target = File.basename(source_path)
    if os_platform =~ /win/
      target_path = dos_path(target_path)
      wrapper = "#{wrapper}.bat"
      script = "@echo off\r\necho |hostname > junk.txt\r\nset /p HOST=<junk.txt\r\necho y | del junk.txt\r\n"
      script += "echo ============== HOSTNAME: %HOST% ==============\r\n"
      script += "echo #{msg} \r\n"
      script += "set RPM_CHANNEL_ROOT=#{target_path}\r\n"
      script += "echo Execute the file\r\n"
      script += "cd %RPM_CHANNEL_ROOT%\r\n"
      script += "#{command} #{target}\r\n"
      script += "echo EXIT_CODE: %errorlevel%\r\n"
      script += "timeout /t <5> /nobreak\r\n"
      script += "echo y|del #{target}\r\n"
    else
      wrapper = "#{wrapper}.sh"
      script = "echo \"============== HOSTNAME: `hostname` ==============\"\n"
      script += "echo #{msg} \n"
      script += "export RPM_CHANNEL_ROOT=\"#{target_path}\"\n"
      script += "echo Execute the file\n"
      script += "cd $RPM_CHANNEL_ROOT\n"
      script += "#{command} #{target}\n"    
      script += "echo EXIT_CODE: $?\n"
      script += "sleep 2\nrm -f #{target}"    
    end
    fil = File.open(File.join(@output_dir, wrapper),"w+")
    fil.puts script
    fil.flush
    fil.close
    File.join(@output_dir, wrapper)
  end

  # Builds the list of files for deployment
  #  assumes that there are 3 sources: version, path entry and uploads
  # ==== Attributes
  #
  # * +p_obj+ - a handle to the current params object
  # * +options+ - hash of options including:
  #
  # ==== Returns
  #
  # array of nsh paths
  #
  def get_artifact_paths(p_obj, options = {})
    files_to_deploy = []
    artifact_path = p_obj.get("step_version_artifact_url", nil)
    artifact_paths = p_obj.split_nsh_path(artifact_path) unless artifact_path.nil?
    path_server = artifact_path.nil? ? "" : artifact_paths[0]
    version = p_obj.get("step_version")    
    staging_server = p_obj.get("staging_server", path_server)
    brpm_hostname = p_obj.get("SS_base_url").gsub(/^.*\:\/\//, "").gsub(/\:\d.*/, "")
    files_to_deploy << p_obj.get_attachment_nsh_path(brpm_hostname, p_obj.get("Upload Action File")) unless p_obj.get("Upload Action File") == ""
    files_to_deploy << p_obj.get_attachment_nsh_path(brpm_hostname, p_obj.uploadfile_1) unless p_obj.uploadfile_1 == ""
    files_to_deploy << p_obj.get_attachment_nsh_path(brpm_hostname, p_obj.uploadfile_2) unless p_obj.uploadfile_2 == ""
    entered_paths = p_obj.get("nsh_paths", p_obj.get("artifact_paths"))
    if entered_paths != ""
      staging_server = "none"
      entered_paths.split(',').each do |path|
        ans = p_obj.split_nsh_path(path)
        staging_server = ans[0] if ans[0].length > 2
        files_to_deploy << "//#{staging_server}#{ans[1].strip}" if ans[1].length > 2
      end
    end
    unless artifact_path.nil?
      staging_server = "none"
      staging_server = artifact_paths[0] if artifact_paths[0].length > 2
      if artifact_path.start_with?("//")
        artifact_paths[1].split(',').each do |path|
          staging = staging_server
          ans = p_obj.split_nsh_path(path)
          staging = ans[0] if ans[0].length > 2
          files_to_deploy << "//#{staging}#{ans[1].strip}" if ans[1].length > 2
        end
      else
        artifact_paths[1].split(',').each do |path|
          files_to_deploy << path
        end
      end
    end
    files_to_deploy
  end  
  
  # Packages files from local staging directory
  # 
  # ==== Attributes
  #
  # * +staging_path+ - path to files
  # * +version+ - version to assign
  # ==== Returns
  #
  # hash of instance_path and md5 - {"instance_path" => "", "md5" => ""}
  def package_staged_artifacts(staging_path, version)
    package_file = "package_#{version}.zip"
    instance_path = File.join(staging_path, package_file)
    staging_artifacts = Dir.entries(staging_path).reject{|k| [".",".."].include?(k) }
    return {"instance_path" => "ERROR - no files in staging area", "md5" => ""} if staging_artifacts.size < 1
    cmd = "cd #{staging_path} && zip -r #{package_file} *" unless Windows
    result = execute_shell(cmd)
    md5 = Digest::MD5.file(instance_path).hexdigest
    {"instance_path" => instance_path, "md5" => md5, "manifest" => staging_artifacts}
  end

  # Return the name or dns of servers in a hash list
  # if dns exists, uses that, otherwise, name
  # ==== Attributes
  #
  # * +servers+ - standard servers hash
  # ==== Returns
  #
  # * array of server dns's
  # 
  def server_dns_names(servers)
    result = []
    servers.each do |name,props|
      if props["dns"].length < 3 || props["dns"].start_with?("http")
        result << name
      else
        result << props["dns"]
      end
    end
    result
  end
  
  # Returns the short name for the os platform
  # Send the OS
  def os_platform(platform, abbrev = true)
    result = "nux"
    result = "nix" if platform.downcase =~ /nix/
    result = "win" if platform.downcase =~ /win/
    result = {"nux" => "unix", "nix" => "linux", "win" => "windows"}[result] unless abbrev
    result
  end

  # Returns plaform information about the first server assigned
  # (works on teh assumption that all assigned servers are similar!)
  # ==== Returns
  #
  # * hash of server information {"server", "os", "channel_root"}
  # 
  def lead_server_info
    servers = BrpmAuto.params.servers
    cur = servers.keys.first
    os = os_platform(servers[cur]["os_platform"], false)
    channel_root = servers[cur].has_key?("CHANNEL_ROOT") ? servers[cur]["CHANNEL_ROOT"] : (os == "windows" ? "C:\\temp" : "/tmp")
    server_info = {"server" => cur, "os" => os, "channel_root" => channel_root}
  end
    
end
