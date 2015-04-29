class BsaRestClient
  def initialize(integration_settings = BrpmAuto.integration_settings)
    @url = integration_settings.dns
    @username = integration_settings.username
    @password = integration_settings.password
    @role = integration_settings.details["role"]

    @api_url = "#{@url}/rest/api/2"
  end

  def get_component_by_name(component_name)
    result = run_query("SELECT * FROM \"SystemObject/Component\" WHERE NAME equals \"#{component_name}\"")

    raise "BSA component '#{component_name}' not found" if result.empty?

    result[0]
  end

  def run_query(query)
    path = "query?bquery=#{query}"

    BrpmAuto.log "Running query #{path}..."
    result = bl_get(path)
    response = result["response"]

    if response.has_key? "ErrorResponse"
      raise "#{response["ErrorResponse"]["Error"]}"
    end

    if response["PropertySetClassChildrenResponse"] && response["PropertySetClassChildrenResponse"]["PropertySetClassChildren"]
      unless response["PropertySetClassChildrenResponse"]["PropertySetClassChildren"]["PropertySetInstances"]["Elements"].empty?
        return response["PropertySetClassChildrenResponse"]["PropertySetClassChildren"]["PropertySetInstances"]["Elements"]
      end
      unless response["PropertySetClassChildrenResponse"]["PropertySetClassChildren"]["Groups"]["Elements"].empty?
        return response["PropertySetClassChildrenResponse"]["PropertySetClassChildren"]["Groups"]["Elements"]
      end
      unless response["PropertySetClassChildrenResponse"]["PropertySetClassChildren"]["PropertySetClasses"]["Elements"].empty?
        return response["PropertySetClassChildrenResponse"]["PropertySetClassChildren"]["PropertySetClasses"]["Elements"]
      end
    end
    []
  end

  private

    def add_credentials(path)
      path + (path.include?("?") ? "&" : "?") + "username=#{@username}&password=#{@password}&role=#{@role}"
    end

    def bl_get(path, options = {})
      Rest.get("#{@url}/#{add_credentials(path)}", options)
    end

    def bl_post(path, data, options = {})
      Rest.post("#{@url}/#{add_credentials(path)}", data, options)
    end

    def bl_put(path, data, options = {})
      Rest.put("#{@url}/#{add_credentials(path)}", data, options)
    end

    def bl_delete(path, options = {})
      Rest.delete("#{@url}/#{add_credentials(path)}", options)
    end
end
