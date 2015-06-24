require "framework/lib/logging/logger_base"

class BrpmLogger < LoggerBase
  def initialize(request_id, automation_results_dir, step_id, run_key, step_number, step_name, also_log_to_console = false)
    @request_id = request_id
    @automation_results_dir = automation_results_dir
    @step_id = step_id
    @run_key = run_key
    @step_number = step_number
    @step_name = step_name
    @also_log_to_console = also_log_to_console

    print "Logging to #{get_step_run_log_file_path} and #{get_request_log_file_path}\n" unless also_log_to_console
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

    prefix = "#{timestamp}|#{'%2.2s' % @step_number}|#{'%-20.20s' % @step_name}|"
    message.gsub!("\n", "\n" + (" " * prefix.length))

    log_message = "#{prefix}#{message}\n"

    File.open(get_request_log_file_path, "a") do |log_file|
      log_file.print(log_message)
    end

#    File.open(get_step_run_log_file_path, "a") do |log_file|
    File.open(BrpmAuto.params.output_file, "a") do |log_file|
      log_file.print(log_message)
    end

    print(log_message) if @also_log_to_console
  end
end
