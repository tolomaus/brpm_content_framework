require_relative "logger_base"

class SimpleLogger < LoggerBase
  def initialize(log_file, also_log_to_console = false)
    @log_file = log_file
    @also_log_to_console = also_log_to_console

    print "Logging to #{@log_file}\n" unless also_log_to_console
  end

  def log(message)
    message = message.to_s # in case booleans or whatever are passed
    timestamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    log_message = ""

    prefix = "#{timestamp}|"
    message = message.gsub("\n", "\n" + (" " * prefix.length))

    log_message = "#{prefix}#{message}\n"

    File.open(@log_file, "a") do |log_file|
      log_file.print(log_message)
    end

    print(log_message) if @also_log_to_console
  end
end
