require_relative "brpm_auto"

class BrpmScriptExecutor
  class << self
    def execute_automation_script(modul, name, params)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading module #{modul}#{params["module_version"] ? " #{params["module_version"]}" : ""} and its dependencies..."
        module_path = BrpmAuto.require_module(modul, params["module_version"])
        BrpmAuto.log "Finished loading the module."

        automation_script_path = "#{module_path}/automations/#{name}.rb"

        BrpmAuto.log "Loading the automation script #{automation_script_path}..."
        load automation_script_path

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log "\n\t" + e.backtrace.join("\n\t")

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

    alias_method :execute_automation_script_from_gem, :execute_automation_script

    def execute_resource_automation_script(modul, name, params, parent_id, offset, max_records)
      begin
        BrpmAuto.setup(params)

        BrpmAuto.log ""
        BrpmAuto.log ">>>>>>>>>>>>>> START resource automation #{name}"
        start_time = Time.now

        BrpmAuto.log "Loading module #{modul} and its dependencies..."
        module_path = BrpmAuto.require_module(modul) #TODO: from where should we get the module version of the script?
        BrpmAuto.log "Finished loading the module."

        automation_script_path = "#{module_path}/resource_automations/#{name}.rb"

        BrpmAuto.log "Loading the resource automation script #{automation_script_path}..."
        load automation_script_path

        BrpmAuto.log "Calling execute_resource_automation_script(params, parent_id, offset, max_records)..."
        execute_script(params, parent_id, offset, max_records)

      rescue Exception => e
        BrpmAuto.log_error "#{e}"
        BrpmAuto.log "\n\t" + e.backtrace.join("\n\t")

        raise e
      ensure
        stop_time = Time.now
        duration = stop_time - start_time

        BrpmAuto.log ">>>>>>>>>>>>>> STOP resource automation #{name} - total duration: #{Time.at(duration).utc.strftime("%H:%M:%S")}"
        BrpmAuto.log ""

        #load "#{File.dirname(__FILE__)}/write_to.rb" if BrpmAuto.params.run_from_brpm
      end
    end

    alias_method :execute_resource_automation_script_from_gem, :execute_resource_automation_script
  end
end

