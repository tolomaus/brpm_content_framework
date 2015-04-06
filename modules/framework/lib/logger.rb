class Logger
  @params = {}

  def self.initialize(params)
    @params = params
    @is_initialized = true
  end

  def self.is_initialized?
    return @is_initialized
  end

  def self.get_request_log_file_path
    "#{@params["SS_automation_results_dir"]}/#{@params["request_id"]}.log"
  end

  def self.get_step_run_log_file_path
    "#{@params["SS_automation_results_dir"]}/#{@params["request_id"]}_#{@params["step_id"]}_#{@params["SS_run_key"]}.log"
  end

  def self.get_log_file_location
    @params["log_file"]
  end

  def self.log(message)
    message = message.to_s # in case booleans or whatever are passed
    timestamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    log_message = ""

    if @params["log_file"]
      prefix = "#{timestamp}|"
      message.gsub!("\n", "\n" + (" " * prefix.length))

      log_message = "#{prefix}#{message}\n"

      File.open(@params["log_file"], "a") do |log_file|
        log_file.print(log_message)
      end
    else
      prefix = "#{timestamp}|#{'%2.2s' % @params["step_number"]}|#{'%-20.20s' % @params["step_name"]}|"
      message.gsub!("\n", "\n" + (" " * prefix.length))

      log_message = "#{prefix}#{message}\n"

      File.open(self.get_request_log_file_path, "a") do |log_file|
        log_file.print(log_message)
      end

      File.open(self.get_step_run_log_file_path, "a") do |log_file|
        log_file.print(log_message)
      end
    end

    print(log_message) if @params.has_key?("local_debug") && @params["local_debug"]=='true'
  end

  def self.log_error(message)
    self.log ""
    self.log "******** ERROR ********"
    self.log "An error has occurred"
    self.log "#{message}"
    self.log "***********************"
    self.log ""
  end
end