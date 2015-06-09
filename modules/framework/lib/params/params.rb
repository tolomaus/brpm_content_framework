class Params < ParamsBase
  attr_reader :application
  attr_reader :component
  attr_reader :component_version

  attr_reader :request_id
  attr_reader :request_name
  attr_reader :request_number
  attr_reader :request_environment
  attr_reader :request_scheduled_at
  attr_reader :request_started_at
  attr_reader :request_status

  attr_reader :request_plan
  attr_reader :request_plan_id
  attr_reader :request_plan_member_id
  attr_reader :request_plan_stage

  attr_reader :request_run_id
  attr_reader :request_run_name

  attr_reader :step_id
  attr_reader :step_number
  attr_reader :step_name
  attr_reader :step_description
  attr_reader :step_estimate

  attr_reader :step_version
  attr_reader :step_version_artifact_url

  attr_reader :servers

  attr_reader :ticket_ids
  attr_reader :tickets_foreign_ids

  attr_reader :run_key

  attr_reader :home_dir
  attr_reader :automation_results_dir
  attr_reader :output_dir
  attr_reader :config_dir

  attr_reader :log_file

  attr_reader :brpm_url
  attr_reader :brpm_api_token

  attr_reader :run_from_brpm
  attr_reader :also_log_to_console

  attr_reader :private_params

  def initialize(params)
    self.merge!(params)

    @application = params["application"]
    @component = params["component"]
    @component_version = params["component_version"]

    @request_id = params["request_id"]
    @request_name = params["request_name"]
    @request_number = params["request_number"]
    @request_environment = params["request_environment"]
    @request_scheduled_at = params["request_scheduled_at"]
    @request_started_at = params["request_started_at"]
    @request_status = params["request_status"]

    @request_plan = params["request_plan"]
    @request_plan_id = params["request_plan_id"]
    @request_plan_member_id = params["request_plan_member_id"]
    @request_plan_stage = params["request_plan_stage"]

    @request_run_id = params["request_run_id"]
    @request_run_name = params["request_run_name"]

    @step_id = params["step_id"]
    @step_number = params["step_number"]
    @step_name = params["step_name"]
    @step_description = params["step_description"]
    @step_estimate = params["step_estimate"]

    @step_version = params["step_version"]
    @step_version_artifact_url = params["step_version_artifact_url"]

    @servers = get_server_list

    @ticket_ids = params["ticket_ids"]
    @tickets_foreign_ids = params["tickets_foreign_ids"]

    @run_key = params["SS_run_key"] || params["run_key"]

    if params["SS_automation_results_dir"]
      @home_dir = params["SS_automation_results_dir"].sub("automation_results", "")
    else
      @home_dir = Dir.pwd
    end
    @automation_results_dir = params["SS_automation_results_dir"]
    @output_dir = params["SS_output_dir"] || params["output_dir"] || Dir.pwd
    @config_dir = "#{@home_dir}/config"

    @log_file = params["log_file"] || "#{@output_dir}/brpm_auto.log"

    @brpm_url = params["SS_base_url"] || params["brpm_url"]
    @brpm_api_token = params["SS_api_token"] || params["brpm_api_token"]

    @run_from_brpm = (@run_key != nil)
    @also_log_to_console = (params["also_log_to_console"] == "true")

    @private_params = {}
    if self.run_from_brpm
      params.each do |k,v|
        if k.end_with?("_encrypt") || k.end_with?("_enc")
          if k.end_with?("_encrypt")
            key_decrypted = k.gsub("_encrypt","")
          elsif k.end_with?("_enc")
            key_decrypted = k.gsub("_enc","")
          end
          value_decrypted = decrypt_string_with_prefix(v)
          @private_params[key_decrypted] = value_decrypted
        end
      end
    end
    self.merge!(@private_params)
  end

  # Servers in params need to be filtered by OS
  def get_servers_by_os_platform(os_platform, alt_servers = nil)
    servers = alt_servers || @servers
    result = servers.select{|k,v| v["os_platform"].downcase =~ /#{os_platform}/ }
  end

  # Fetches the property value for a server
  #
  # ==== Returns
  #
  # * property value
  def get_server_property(server, property)
    ans = ""
    ans = @servers[server][property] if @servers.has_key?(server) && @servers[server].has_key?(property)
    ans
  end

  # Gets a params
  #
  # ==== Attributes
  #
  # * +key+ - key to find
  def get(key, default_value = "")
    result = self[key] || default_value

    BrpmAuto.substitute_tokens(result)
  end

  # Adds a key/value to the params
  #
  # ==== Attributes
  #
  # * +key_name+ - key name
  # * +value+ - value to assign
  #
  # ==== Returns
  #
  # * value added
  def add(key_name, value)
    self[key_name] = value
  end

  # Adds a key/value to the params if not found
  #
  # ==== Attributes
  #
  # * +key_name+ - key name
  # * +value+ - value to assign
  #
  # ==== Returns
  #
  # * value of key
  def find_or_add(key_name, value)
    ans = get(key_name)
    add(key_name, value) if ans == ""
    ans == "" ? value : ans
  end

  # Returns the request id for use in rest calls
  #
  def rest_request_id
    (self["request_id"].to_i - 1000).to_s
  end

  private

    def get_server_list()
      rxp = /server\d+_/
      slist = {}
      lastcur = -1
      curname = ""

      self.sort.reject{ |k| k[0].scan(rxp).empty? }.each_with_index do |server, idx|
        cur = (server[0].scan(rxp)[0].gsub("server","").to_i * 0.001).round * 1000
        if cur == lastcur
          prop = server[0].gsub(rxp, "")
          slist[curname][prop] = server[1]
        else # new server
          lastcur = cur
          curname = server[1].chomp("0")
          slist[curname] = {}
        end
      end
      return slist
    end
end
