class SimpleLogger
  def initialize(log_file, debug = false)
    @log_file = log_file
    @debug = debug
  end

  def log(message)
    message = message.to_s # in case booleans or whatever are passed
    timestamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    log_message = ""

    prefix = "#{timestamp}|"
    message.gsub!("\n", "\n" + (" " * prefix.length))

    log_message = "#{prefix}#{message}\n"

    File.open(@log_file, "a") do |log_file|
      log_file.print(log_message)
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
