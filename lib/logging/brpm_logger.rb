require_relative "logger_base"

class BrpmLogger < LoggerBase
  attr_reader :request_log_file_path
  attr_reader :step_run_log_file_path

  def initialize
    @step_number = BrpmAuto.params.step_number
    @step_name = BrpmAuto.params.step_name

    @request_log_file_path = "#{BrpmAuto.params.automation_results_dir}/#{BrpmAuto.params.request_id}.log"

    # @step_run_log_file_path = "#{BrpmAuto.params.automation_results_dir}/#{BrpmAuto.params.request_id}_#{BrpmAuto.params.step_id}_#{BrpmAuto.params.run_key}.log"
    @step_run_log_file_path = BrpmAuto.params.output_file

    print "Logging to #{@step_run_log_file_path} and #{@request_log_file_path}\n" unless BrpmAuto.params.also_log_to_console
  end

  def log(message)
    message = message.to_s # in case booleans or whatever are passed
    timestamp = "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"
    log_message = ""

    prefix = "#{timestamp}|#{'%2.2s' % @step_number}|#{'%-20.20s' % @step_name}|"
    message.gsub!("\n", "\n" + (" " * prefix.length))

    log_message = "#{prefix}#{message}\n"

    File.open(@request_log_file_path, "a") do |log_file|
      log_file.print(log_message)
    end

    File.open(@step_run_log_file_path, "a") do |log_file|
      log_file.print(log_message)
    end

    print(log_message) if BrpmAuto.params.also_log_to_console
  end
end
