require "framework/lib/rest_api"

module BsaRest
  class Core
    def self.initialize(url, username, password, role)
      @url = url
      @username = username
      @password = password
      @role = role
    end

    def self.run_query(query)
      path = "query?bquery=#{query}"

      Logger.log "Running query #{path}..."
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

    def self.add_credentials(path)
      path + (path.include?("?") ? "&" : "?") + "username=#{@username}&password=#{@password}&role=#{@role}"
    end

    def self.bl_get(path, options = {})
      rest_get("#{@url}/#{add_credentials(path)}", options)
    end

    def self.bl_post(path, data, options = {})
      rest_post("#{@url}/#{add_credentials(path)}", data, options)
    end

    def self.bl_put(path, data, options = {})
      rest_put("#{@url}/#{add_credentials(path)}", data, options)
    end

    def self.bl_delete(path, options = {})
      rest_delete("#{@url}/#{add_credentials(path)}", options)
    end

  end
end