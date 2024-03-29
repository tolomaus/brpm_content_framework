require 'rest-client'
require 'uri'
require 'json'
require 'cgi'

class Rest
  class << self
    def get(url, options = {})
      rest_call(url, "get", options)
    end

    def post(url, data, options = {})
      options[:data] = data
      rest_call(url, "post", options)
    end

    def put(url, data, options = {})
      options[:data] = data
      rest_call(url, "put", options)
    end

    def delete(url, options = {})
      rest_call(url, "delete", options)
    end

    # Makes an http method call and returns data in JSON
    #
    # ==== Attributes
    #
    # * +url+ - the url for the request
    # * +method+ - the http method [get, put, post]
    # * +options+ - a hash of options
    #      +verbose+: gives verbose output (yes/no)
    #      +data+: required for put and post methods a hash of post data
    #      +username+: username for basic http authentication
    #      +password+: password for basic http authentication
    #      +suppress_errors+: continues after errors if true
    #      
    # ==== Returns
    #
    # * returns a hash of the http response with these keys
    # * +status+ - success or ERROR
    # * +message+ - if status is ERROR this will hold an error message
    # * +code+ - the http status code 200=ok, 404=not found, 500=error, 504=not authorized
    # * +data+ - the body of the http response
    def rest_call(url, method, options = {})
      methods = %w{get post put delete}
      result = rest_params = {}
      rest_params[:url] = URI.escape(url)

      unless methods.include?(method.downcase)
        BrpmAuto.log "No method named: #{method}"
        result["code"] = -1
        result["status"] = "failure"
        result["message"] = "No method named: #{method}"
        return result
      end

      rest_params[:method] = method.downcase

      begin
        BrpmAuto.log("REST #{method.upcase} #{BrpmAuto.privatize(url, get_token(url))}") unless options.has_key?("quiet")

        if options.has_key?(:username) && options.has_key?(:password)
          rest_params[:user] = options[:username]
          rest_params[:password] = options[:password]
        end

        if %{put post}.include?(method.downcase)
          options[:data] = options["data"] if options.has_key?("data")
          rest_params[:payload] = options[:data].to_json if options.has_key?(:data)
          if !options.has_key?(:data) || rest_params[:payload].length < 4
            result["code"] = -1
            result["status"] = "failure"
            result["message"] = "No Post data"
            return result
          end
          BrpmAuto.log "\tPost Data: #{rest_params[:payload].inspect}" unless options.has_key?("quiet")
        end

        rest_params.merge!({:headers => { :accept => :json, :content_type => :json }})
        rest_params.merge!({:verify_ssl => OpenSSL::SSL::VERIFY_NONE})
        rest_params.merge!({:cookies => options["cookies"] }) if options.has_key?("cookies")

        BrpmAuto.log rest_params.inspect if options.has_key?("verbose")

        response = RestClient::Request.new(rest_params).execute

        BrpmAuto.log "\tParsing response to JSON format ..." if options.has_key?("verbose")
        begin
          parsed_response = JSON.parse(response)
        rescue
          parsed_response = response
        end
        BrpmAuto.log "Parsed response: #{parsed_response.inspect}" if options.has_key?("verbose")

        if response.code < 300
          BrpmAuto.log "\treturn code: #{response.code}"  unless options.has_key?("quiet")
          result["status"] = "success"
          result["code"] = response.code
          result["response"] = parsed_response
          result["cookies"] = response.cookies if options.has_key?("cookies")
        else
          result["status"] = "error"
          result["code"] = response.code
          result["response"] = parsed_response
          result["error_message"] = "REST call returned HTTP code:\n#{response.code}\n#{response}"
          BrpmAuto.log "\tREST call returned HTTP code #{response.code}"  unless options.has_key?("quiet")
        end

      rescue RestClient::Exception => e
        BrpmAuto.log "\tREST call generated an error: #{e.message}" unless options.has_key?("quiet")

        if e.response.nil?
          result["status"] = "error"
          result["code"] = 1000
          result["response"] = "No response received."
          result["error_message"] = "REST call generated a RestClient error:\n#{e.message}\n#{e.backtrace}"
          return
        end

        BrpmAuto.log "\tParsing response to JSON format ..."  unless options.has_key?("quiet")
        begin
          parsed_response = JSON.parse(e.response)
        rescue
          parsed_response = e.response
        end
        BrpmAuto.log "\tParsed response: #{parsed_response.inspect}"

        result["status"] = "error"
        result["code"] = e.response.code
        result["response"] = parsed_response
        result["error_message"] = "REST call generated a RestClient error:\n#{e.response.code}\n#{e.response}\n#{e.message}\n#{e.backtrace}"

        BrpmAuto.log "Back trace:\n#{e.backtrace}" unless already_exists_error(result) or not_found_error(result)
      end
      result
    end

    def already_exists_error(result)
      result["code"] == 422 && result["response"].keys.count >= 1 && (result["response"][result["response"].keys[0]][0] == "has already been taken" || result["response"][result["response"].keys[0]][0] =~ /Version Tag is not unique/)
    end

    def not_found_error(result)
      result["code"] == 404
    end

    private

      def get_token(url)
        params = CGI::parse(url.split("?").last)
        params.has_key?("token") ? params["token"] : ""
      end
  end
end
