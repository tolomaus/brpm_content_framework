@p = BrpmAuto.all_params

result = run_command(params, @p.get("command"),"")

# Apply success or failure criteria
if result.include?(@p.get("success"))
  BrpmAuto.log "Success - found term: #{@p.get("success")}\n"
else
  BrpmAuto.log "Command_Failed - term not found: [#{@p.get("success")}]\n"
end
