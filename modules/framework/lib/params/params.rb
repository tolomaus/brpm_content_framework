class Params < Hash
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

  attr_reader :automation_results_dir
  attr_reader :output_dir

  attr_reader :log_file

  attr_reader :brpm_url
  attr_reader :brpm_api_token

  attr_reader :run_from_brpm
  attr_reader :also_log_to_console

  attr_reader :private_values

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

    @run_key = params["SS_run_key"]

    @automation_results_dir = params["SS_automation_results_dir"]
    @output_dir = params["SS_output_dir"] || params["output_dir"] || Dir.pwd

    @log_file = params["log_file"] || "#{@output_dir}/brpm_auto.log"

    @brpm_url = params["SS_base_url"] || params["brpm_url"]
    @brpm_api_token = params["SS_api_token"] || params["brpm_api_token"]

    @run_from_brpm = (@run_key != nil)
    @also_log_to_console = (params["also_log_to_console"] == "true")

    @private_values = []
    params.each{|k,v| @private_values << params[k.gsub("_encrypt","")] if k.end_with?("_encrypt") }
  end

  # Gets a params
  #
  # ==== Attributes
  #
  # * +key+ - key to find
  def get(key, default_value = "")
    result = self.has_key?(key) ? self[key] : nil
    result = default_value if result.nil? || result == ""
    result
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
