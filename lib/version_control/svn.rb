require 'uri'

# Base class for working with Subversion
class Svn
  
  # Initializes an instance of the class
  #
  # ==== Attributes
  #
  # * +svn+ - path to the svn executable
  # * +params+ - params hash
  # * +options+ - hash of options includes:...
  #   url - url for svn repository...
  #   base_path - path for the local repository...
  #   username - repository user username...
  #   password - repository user password...
  #   verbose - true for verbose output (default = false)...
  #   rebase - starting path for checkouts...
  #   simulate - simulate command - echo it (default = false)...
  #   prerun_lines - pass any text to run before svn (such as env variables)...
  #   command_options - options to pass on command line e.g. --non-interactive
  #
  def initialize(svn, params, options)
    self.extend Utilities
    @url = required_option(options,"url")
    @base_path = required_option(options,"base_path")
    user = get_option(options,"username")
    @password = get_option(options,"password")
    @verbose = get_option(options,"verbose", false)
    @prerun = get_option(options, "prerun_lines")
    @command_options = get_option(options, "command_options")
    @command_options += " --non-interactive" unless @command_options.include?("non-interactive")
    @rebase = get_option(options, "rebase")
    @rebase =  @url.split("/")[-1] if @rebase == ""
    @simulate = get_option(options,"simulate", false)
    make_credential(user, @password)
    @svn = svn
  end
 
  # Parses a complex svn uri into parts
  #
  # ==== Attributes
  #
  # * +svn_url+ - svn url, like this:...
  # https://user:password@host:port/path/path[#revision]...
  # https://user:password@svn.nam.nsroot.net:9050/svn/16667/appreldep/RLM/artifacts/CATE[7777777]
  # * +reset_values+ - resets the svn object parameters host, password etc from url (default=false)
  #
  # ==== Returns
  #
  # * parse result, like this:...
  # {"uri_result" => URIGemResult, "revision" => ""}
  def parse_uri(svn_uri, reset_values = false)
    result = {"uri_result" => nil, "revision" => ""}
    k = svn_uri.scan(/\[.*\]/)
    result["revision"] = k[0].gsub("[","").gsub("]","") if k.size > 0
    rev = k.size > 0 ? "[#{result["revision"]}]" : "__ZZZ__"
    parts = URI.parse(svn_uri.gsub(rev,""))
    result["uri_result"] = parts
    if reset_values
      @url = "#{parts.scheme}://#{parts.host}:#{parts.port}#{parts.path}"
      make_credential(parts.user, parts.password) unless parts.password.nil?
    end
    result
  end

  # Performs an svn checkout
  #
  # ==== Attributes
  #
  # * +init+ - true to initilize the checkout and local repo
  # ==== Returns
  #
  # * command output
  def checkout(init = false)
    FileUtils.cd(@base_path, :verbose => true)
    if init
      cmd = "#{@svn} checkout #{@url} #{@rebase}  #{@credential} #{@command_options}"
    else
      cmd = "#{@svn} checkout  #{@command_options}"
    end
    process_cmd(cmd)
  end

  # Performs an svn export
  #
  # ==== Attributes
  #
  # * +revision+ - revision to export (options - defaults to latest)
  # ==== Returns
  #
  # * command output
  def export(target = "", revision = "")
    url_items = URI.parse(@url)
    target = url_items.path if target == ""    
    cmd_options = @command_options
    cmd_options += " --no-auth-cache --trust-server-cert --force" if cmd_options == " --non-interactive"
    base_cmd = "#{@svn} export #{@credential} #{@command_options} #{@url}"
    FileUtils.cd(@base_path, :verbose => true)
    if revision == ""
      cmd = "#{base_cmd} ."
    else
      cmd = "#{base_cmd} -r #{revision} ."
    end
    process_cmd(cmd)
  end

  # Performs an svn checkout
  #
  # ==== Returns
  #
  # * command output
  def get
    cmd = "#{@svn} checkout --non-interactive"
    process_cmd(cmd)
  end
  
  # Performs an svn commit
  #
  # ==== Attributes
  #
  # * +message+ - commit string
  # ==== Returns
  #
  # * command output
  def commit(message = "Automation pushed changes")
    # /usr/bin/svn commit . -m "PSENG-0000 Adding PSENG files"
    cmd = "#{@svn} commit . -m \"#{message}\""
    process_cmd(cmd)
  end
  
  # Performs an svn tag
  #
  # ==== Attributes
  #
  # * +source_path+ - path in repo to tag
  # * +tag_name+ - name for tag
  # * +message+ - message to add to tag
  #
  # ==== Returns
  #
  # * command output
  def tag(source_path, tag_name, message)
    ipos = @url.index("trunk")
    raise "Cannot locate trunk path" if ipos.nil?
    tag_path = @url[0..ipos] + "tags/" + tag_name
    cmd = "#{@svn} copy #{source_path} #{tag_path} -m \"#{message}\""
    process_cmd(cmd)
  end
  
  # Performs an svn status
  #
  # ==== Returns
  #
  # * command output
  def status
    process_cmd("#{@svn} status")
  end
  
  # Adds any new files in the local repo to the svn commit list
  #
  # ==== Attributes
  #
  # * +exclude_regex+ - regex to filter add files (file !=~ filter)
  #
  # ==== Returns
  #
  # * command output
  def add_files(options = {})
    result = status
    msg = ""
    exclude = get_option(options,"exclude_regex")
    result.split("\n").each do |item|
      if item.start_with?("?")
        file = item.gsub("?","").strip
        cmd = "#{@svn} add #{file}"
        if exclude == ""
          msg += process_cmd(cmd)
        else
          msg += process_cmd(cmd) if file =~ /#{exclude}/
        end
        res = `#{cmd}`
      end
    end
    "#{result}\n#{msg}"
  end

  private        
  
  def process_cmd(cmd)
    goto_base
    cmd = "#{@prerun} && #{cmd}" unless @prerun == ""
    res = execute_shell(cmd) unless @simulate
    BrpmAuto.log cmd.gsub(@password,"-private-") if @verbose || @simulate
    @simulate ? "ok" : display_result(res)
  end
  
  def goto_base
    @pwd = FileUtils.pwd
    goto_path = @base_path #@rebase != "" ? File.join(@base_path,@rebase) : @base_path
    FileUtils.cd(goto_path, :verbose => true) if @verbose
    FileUtils.cd(goto_path) unless @verbose
  end

  def svn_errors?(output)
    svn_terms = ["403 Forbidden", "SSL error code", "moorrreee"]
    found = output.scan(/#{svn_terms.join("|")}/)
    found.size > 0
  end
  
  def make_credential(user, password)
    if user.to_s != "" && password.to_s != ""
      @credential = " --username #{user} --password #{password}"
    else
      @credential = ""
    end
  end

end


