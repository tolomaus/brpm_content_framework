class BsaRest
  class << self
    def setup(url, username, password, role)
      @url = url
      @username = username
      @password = password
      @role = role
    end

    def run_query(query)
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

      def get_url
        @url || BrpmAuto.integration_server_settings.dns
      end

      def get_username
        @username || BrpmAuto.integration_server_settings.username
      end

      def get_password
        @password || BrpmAuto.integration_server_settings.password
      end

      def get_role
        @role || BrpmAuto.integration_server_settings.details["role"]
      end

      def add_credentials(path)
        path + (path.include?("?") ? "&" : "?") + "username=#{get_username}&password=#{get_password}&role=#{get_role}"
      end

      def bl_get(path, options = {})
        Rest.get("#{get_url}/#{add_credentials(path)}", options)
      end

      def bl_post(path, data, options = {})
        Rest.post("#{get_url}/#{add_credentials(path)}", data, options)
      end

      def bl_put(path, data, options = {})
        Rest.put("#{get_url}/#{add_credentials(path)}", data, options)
      end

      def bl_delete(path, options = {})
        Rest.delete("#{get_url}/#{add_credentials(path)}", options)
      end
  end
end
