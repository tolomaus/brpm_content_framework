require "#{File.dirname(__FILE__)}/brpm_auto"

class BrpmScriptExecutor
  class << self
    def execute_automation_script(modul, name, params)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading the dependencies..."
        BrpmAuto.require_module(modul)

        automation_script_path = "#{modul}/automations/#{name}.rb"

        BrpmAuto.log "Loading #{automation_script_path}..."
        load automation_script_path

        if defined?(execute_script)
          BrpmAuto.log "Calling execute_script(params)..."
          execute_script(params)
        end

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = 0
        duration = stop_time - start_time unless start_time.nil?

        BrpmAuto.log ">>>>>>>>>>>>>> STOP automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        write_to(File.read(BrpmAuto.logger.get_step_run_log_file_path)) if defined? write_to
      end

      BrpmAuto.output_params
    end

    def execute_resource_automation_script(modul, name, params, parent_id, offset, max_records)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START resource automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading the dependencies..."
        BrpmAuto.require_module(modul)

        automation_script_path = "#{modul}/resource_automations/#{name}.rb"

        BrpmAuto.log "Loading #{automation_script_path}..."
        load automation_script_path

        BrpmAuto.log "Calling execute_resource_automation_script(params, parent_id, offset, max_records)..."
        execute_resource_automation_script(params, parent_id, offset, max_records)

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = stop_time - start_time

        BrpmAuto.log ">>>>>>>>>>>>>> STOP resource automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        write_to(File.read(BrpmAuto.get_step_run_log_file_path)) if defined? write_to
      end

      BrpmAuto.output_params
    end
  end
end