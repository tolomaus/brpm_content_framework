# Creates a pid-file semaphore to govern global execution
#
# ==== Attributes
#
# * +semaphore_key+ - string to name semaphore
# ==== Returns
#
# true if semaphore created, false if already exists
#
def semaphore(semaphore_key)
  semaphore_dir = "#{BrpmAuto.params.automation_results_dir}/semaphores"
  semaphore_name = "#{semaphore_key}.pid"
  FileUtils.mkdir(semaphore_dir) unless File.exist?(semaphore_dir)
  return false if File.exist?(File.join(semaphore_dir, semaphore_name))
  fil = File.open(File.join(semaphore_dir, semaphore_name), "w+")
  fil.puts BrpmAuto.precision_timestamp
  fil.flush
  fil.close
  return true
end

# Clears a pid-file semaphore to govern global execution
#
# ==== Attributes
#
# * +semaphore_key+ - string to name semaphore
# ==== Returns
#
# true if semaphore deleted, false if it doesn't exist
#
def semaphore_clear(semaphore_key)
  semaphore_dir = "#{BrpmAuto.params.automation_results_dir}/semaphores"
  semaphore_name = "#{semaphore_key}.pid"
  return false unless File.exist?(File.join(semaphore_dir, semaphore_name))
  File.delete(File.join(semaphore_dir, semaphore_name))
  return true
end

# Checks if a semaphore exists
#
# ==== Attributes
#
# * +semaphore_key+ - string to name semaphore
# ==== Returns
#
# true if semaphore exists, false if it doesn't exist
#
def semaphore_exists(semaphore_key)
  semaphore_dir = "#{BrpmAuto.params.automation_results_dir}/semaphores"
  semaphore_name = "#{semaphore_key}.pid"
  return true if File.exist?(File.join(semaphore_dir, semaphore_name))
  return false
end

# Waits a specified period for a semaphore to clear
# throws error after wait time if semaphore does not clear
# ==== Attributes
#
# * +semaphore_key+ - string to name semaphore
# * +wait_time+ - time in minutes before failure (default = 15mins)
# ==== Returns
#
# true if semaphore is cleared
#
def semaphore_wait(semaphore_key, wait_time = 15)
  interval = 20; elapsed = 0
  semaphore_dir = "#{BrpmAuto.params.automation_results_dir}/semaphores"
  semaphore_name = "#{semaphore_key}.pid"
  semaphore = File.join(semaphore_dir, semaphore_name)
  return true if !File.exist?(semaphore)
  until !File.exist?(semaphore) || (elapsed/60 > wait_time) do
    sleep interval
    elapsed += interval
  end
  if File.exist?(semaphore)
    raise "ERROR: Semaphore (#{semaphore}) still exists after #{wait_time} minutes"
  end
  return true
end
