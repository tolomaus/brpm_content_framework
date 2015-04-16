class Logger
  class << self
    def setup(log_file)
      @log_file = log_file
    end
  
    def get_request_log_file_path
      "#{BrpmAuto.automation_results_dir}/#{BrpmAuto.request_id}.log"
    end
  
    def get_step_run_log_file_path
      "#{BrpmAuto.automation_results_dir}/#{BrpmAuto.request_id}_#{BrpmAuto.step_id}_#{BrpmAuto.run_key}.log"
    end
  
    def log(message)
      message = message.to_s # in case booleans or whatever are passed
      timestamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
      log_message = ""
  
      if @log_file
        prefix = "#{timestamp}|"
        message.gsub!("\n", "\n" + (" " * prefix.length))
  
        log_message = "#{prefix}#{message}\n"
  
        File.open(@log_file, "a") do |log_file|
          log_file.print(log_message)
        end
      elsif BrpmAuto.is_set_up
        prefix = "#{timestamp}|#{'%2.2s' % BrpmAuto.step_number}|#{'%-20.20s' % BrpmAuto.step_name}|"
        message.gsub!("\n", "\n" + (" " * prefix.length))
  
        log_message = "#{prefix}#{message}\n"
  
        File.open(get_request_log_file_path, "a") do |log_file|
          log_file.print(log_message)
        end
  
        File.open(get_step_run_log_file_path, "a") do |log_file|
          log_file.print(log_message)
        end
      else
        raise "Logger is not set up correctly."
      end
  
      print(log_message) if BrpmAuto.debug
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
