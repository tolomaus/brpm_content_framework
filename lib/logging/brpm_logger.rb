require_relative "logger_base"

class BrpmLogger < LoggerBase
  attr_reader :request_log_file_path
  attr_reader :step_run_log_file_path

  def initialize
    @step_number = BrpmAuto.params.step_number
    @step_name = BrpmAuto.params.step_name

    @request_log_file_path = "#{BrpmAuto.params.automation_results_dir}/#{BrpmAuto.params.request_id}.log"

    @step_run_log_file_path = "#{BrpmAuto.params.automation_results_dir}/#{BrpmAuto.params.request_id}_#{BrpmAuto.params.step_id}_#{BrpmAuto.params.run_key}.log"

    print "Logging to #{@step_run_log_file_path} and #{@request_log_file_path}\n" unless BrpmAuto.params.also_log_to_console
  end

  def log(message, with_prefix = true)
    message = message.to_s # in case booleans or whatever are passed
    timestamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"

    if with_prefix
      prefix = "#{timestamp}|#{'%2.2s' % @step_number}|#{'%-20.20s' % @step_name}|"
      message.gsub!("\n", "\n" + (" " * prefix.length))
    else
      prefix = ""
    end

    log_message = "#{prefix}#{message}\n"

    print(log_message) if BrpmAuto.params.also_log_to_console

    File.open(@request_log_file_path, "a") do |log_file|
      log_file.print(log_message)
    end

    File.open(@step_run_log_file_path, "a") do |log_file|
      log_file.print(log_message)
    end
  end
end
