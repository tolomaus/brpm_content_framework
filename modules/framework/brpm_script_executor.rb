require_relative "brpm_auto"

class BrpmScriptExecutor
  class << self
    def execute_automation_script(modul, name, params)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading the dependencies..."
        module_path = BrpmAuto.require_module(modul)
        BrpmAuto.log "Finished loading the dependencies."

        automation_script_path = "#{module_path}/automations/#{name}.rb"

        BrpmAuto.log "Loading the automation script #{automation_script_path}..."
        load automation_script_path

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

        #load "#{File.dirname(__FILE__)}/write_to.rb" if BrpmAuto.params.run_from_brpm
      end
    end

    def execute_resource_automation_script(modul, name, params, parent_id, offset, max_records)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START resource automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading the dependencies..."
        module_path = BrpmAuto.require_module(modul)
        BrpmAuto.log "Finished loading the dependencies."

        automation_script_path = "#{module_path}/resource_automations/#{name}.rb"

        BrpmAuto.log "Loading the resource automation script #{automation_script_path}..."
        result = load automation_script_path

        BrpmAuto.log "Calling execute_resource_automation_script(params, parent_id, offset, max_records)..."
        execute_script(params, parent_id, offset, max_records)

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = stop_time - start_time

        BrpmAuto.log ">>>>>>>>>>>>>> STOP resource automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        #load "#{File.dirname(__FILE__)}/write_to.rb" if BrpmAuto.params.run_from_brpm
      end
    end
  end
end

