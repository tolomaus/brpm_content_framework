require "bladelogic/lib/core"
require "framework/lib/rest_api"

module BsaRest
  class Component < Core
    def self.get_component_by_name(component_name)
      result = run_query("SELECT * FROM \"SystemObject/Component\" WHERE NAME equals \"#{component_name}\"")

      raise "BSA component '#{component_name}' not found" if result.empty?

      result[0]
    end
  end
end