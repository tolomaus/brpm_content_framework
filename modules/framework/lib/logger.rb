class Logger
  private_class_method :new

  class << self
    def setup(log_file, debug = false)
      @log_file = log_file
      @debug = debug
    end
  
    def setup_for_automation_script(request_id, automation_results_dir, step_id, run_key, step_number, step_name, debug = false)
      @request_id = request_id
      @automation_results_dir = automation_results_dir
      @step_id = step_id
      @run_key = run_key
      @step_number = step_number
      @step_name = step_name
      @debug = debug

      @brpm_auto = true
    end

    def get_request_log_file_path
      "#{@automation_results_dir}/#{@request_id}.log"
    end
  
    def get_step_run_log_file_path
      "#{@automation_results_dir}/#{@request_id}_#{@step_id}_#{@run_key}.log"
    end
  
    def log(message)
      message = message.to_s # in case booleans or whatever are passed
      timestamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
      log_message = ""
  
      if @brpm_auto
        prefix = "#{timestamp}|#{'%2.2s' % @step_number}|#{'%-20.20s' % @step_name}|"
        message.gsub!("\n", "\n" + (" " * prefix.length))
  
        log_message = "#{prefix}#{message}\n"
  
        File.open(get_request_log_file_path, "a") do |log_file|
          log_file.print(log_message)
        end
  
        File.open(get_step_run_log_file_path, "a") do |log_file|
          log_file.print(log_message)
        end
      elsif @log_file
          prefix = "#{timestamp}|"
          message.gsub!("\n", "\n" + (" " * prefix.length))

          log_message = "#{prefix}#{message}\n"

          File.open(@log_file, "a") do |log_file|
            log_file.print(log_message)
          end
      else
        raise "Logger is not set up correctly."
      end
  
      print(log_message) if @debug
    end
  
    def log_error(message)
      log ""
      log "******** ERROR ********"
      log "An error has occurred"
      log "#{message}"
      log "***********************"
      log ""
    end
  end
end
