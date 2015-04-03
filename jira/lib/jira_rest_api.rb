require 'json'
require 'rest-client'
require 'uri'

#=============================================================================#
# Jira Rest Module                                                            #
#-----------------------------------------------------------------------------#
# The REST module currently supports the 6.0.8 version of the Jira API as     #
# well as a rest client which supports both HTTP and HTTPS                    #
#=============================================================================#
module Jira
  def self.REST_VERSION
    "6.0.8"
  end

  class Client
    def initialize(user, pw, url)
      @username = user
      @password = pw
      @url = url
      @api_url  = "#{url}/rest/api/2"
      @auth_url = "#{url}/rest/auth/1"
    end

    attr_reader :username
    attr_reader :password
    attr_reader :cookie
    attr_reader :url
    attr_reader :api_url
    attr_reader :auth_url

    # POST /auth/api/1/session
    def login()
      login = {:username => "#{@username}", :password => "#{@password}"}.to_json
      resp = post("#{@auth_url}/session", login)
      @cookie = resp.cookies
      @password = ''		# clear password as not needed once we login
    end

    # DELETE /auth/api/1/session
    def logout()
      resp = delete("#{@auth_url}/session")
      @cookie = ''
    end

    # POST /rest/api/2/issue/{issueIdOrKey}/comment
    def create_comment(issue_id, comment_body = 'Dummy Comment')
      cmmnt = {:body => comment_body}.to_json
      post_json("#{@api_url}/issue/#{issue_id}/comment", cmmnt)
    end

    # GET /rest/api/2/issue/{issueIdOrKey}/transitions[?expand=transitions.fields]
    def get_issue_transitions(issue_id, expand_transition = false)
      url = "#{@api_url}/issue/#{issue_id}/transitions"
      if expand_transition
        url = "#{url}?expand=transitions.fields"
      end
      get_json(url)
    end

    # GET /rest/api/2/issue/{issueIdOrKey}/transitions?transitionId={transistion_id}[&expand=transitions.fields]
    def get_issue_transition(issue_id, transition_id, expand_transition = false)
      url = "#{@api_url}/issue/#{issue_id}/transitions?transitionId=#{transition_id}"
      if expand_transition
          url = "#{url}&expand=transitions.fields"
      end
      get_json(url)
    end

    # POST /rest/api/2/issue/{issueIdOrKey}/transitions[?expand=transitions.fields]
    def post_issue_transition(issue_id, transition_id, comment = 'simple comment', expand_transition = false)
      url = "#{@api_url}/issue/#{issue_id}/transitions"
      if expand_transition
        url = "#{url}?expand=transitions.fields"
      end
      transition = {:update=>{:comment =>[{:add => {:body => "#{comment}"}}]}, :transition => {:id => "#{transition_id}"}}.to_json
      #Simple post as only return code is returned
      post(url, transition)
    end

    # GET /rest/api/2/project
    def get_projects()
      get_json("#{@api_url}/project")
    end

    def set_issue_to_status(issue_id, status)
      Logger.log "Getting the possible transitions for issue #{issue_id}..."
      result = self.get_issue_transitions(issue_id)
      transitions = result["transitions"]

      transition = transitions.find { |transition| transition["name"] == status }

      if transition
        Logger.log "Issuing transition #{transition["name"]} to update the status of the issue to #{status}..."
        issues = self.post_issue_transition(params["issue_id"], transition["id"])
      else
        Logger.log "This ticket does not have a transition to status #{params["target_issue_status"]} currently. Leaving it in its current state."
      end
    end

    # GET /rest/api/2/search?jql=[Some Jira Query Language Search][&startAt=<num>&maxResults=<num>&fields=<field,field,...>&expand=<param,param,...>]
    def search(jql, start_at = 0, max_results = 50, fields = '', expand = '')
      url = "#{@api_url}/search?jql=#{jql}"
      url = "#{url}&startAt=#{start_at}" unless start_at == 0
      url = "#{url}&maxResults=#{max_results}" unless max_results == 50
      url = "#{url}&fields=#{fields}" unless fields == ''
      url = "#{url}&expand=#{expand}" unless expand == ''
      get_json(url)
    end

    # GET /rest/api/2/issue/{issueIdOrKey}[?fields=<field,field,...>&expand=<param,param,...>]
    def get_issue(issue_id, fields = '', expand = '')
      added = false
      url = "#{@api_url}/issue/#{issue_id}"
      if not fields.eql? ''
        url = "#{url}?fields=#{fields}"
        added = true
      end
      if not expand.eql? ''
        if added
          url = "#{url}&expand=#{expand}"
        else
          url = "#{url}?expand=#{expand}"
        end
      end
      get_json(url)
    end

    def get_option_for_dropdown_custom_field(custom_field_id, option_value)
      # NOTE: this method assumes that the "Customfield Editor Plugin" is installed on the JIRA instance and that permission was granted for the custom field

      url = "#{@url}/rest/jiracustomfieldeditorplugin/1.1/user/customfieldoptions/custom_field_#{custom_field_id}"
      custom_field_options = get_json(url)

      custom_field_id.find { |custom_field_option| custom_field_option["optionvalue"] == option_value }
    end

    def create_option_for_dropdown_custom_field(custom_field_id, option_value)
      # NOTE: this method assumes that the "Customfield Editor Plugin" is installed on the JIRA instance and that permission was granted for the custom field

      url = "#{@url}/rest/jiracustomfieldeditorplugin/1.1/user/customfieldoption/custom_field_#{custom_field_id}"
      data = {:optionvalue => option_value }.to_json

      post_json(url, data)
    end

    def update_option_for_dropdown_custom_field(custom_field_id, old_option_value, new_option_value)
      # NOTE: this method assumes that the "Customfield Editor Plugin" is installed on the JIRA instance and that permission was granted for the custom field

      custom_field_option_to_update = get_option_for_dropdown_custom_field(custom_field_id, old_option_value)

      if custom_field_option_to_update
        url = "#{@url}/rest/jiracustomfieldeditorplugin/1.1/user/customfieldoption/custom_field_#{custom_field_id}/#{custom_field_option_to_update["id"]}"
        data = {:optionvalue => new_option_value }.to_json

        put_json(url, data)
      else
        create_option_for_dropdown_custom_field(custom_field_id, new_option_value)
      end
    end

    def delete_option_for_dropdown_custom_field(custom_field_id, option_value)
      # NOTE: this method assumes that the "Customfield Editor Plugin" is installed on the JIRA instance and that permission was granted for the custom field

      custom_field_option_to_delete = get_option_for_dropdown_custom_field(custom_field_id, option_value)

      if custom_field_option_to_delete
        url = "#{@url}/rest/jiracustomfieldeditorplugin/1.1/user/customfieldoption/custom_field_#{custom_field_id}/#{custom_field_option_to_update["id"]}"

        delete_json(url)
      end
    end

    private
    # JSON Styled RESTful GET
    def get_json(url)
      JSON.parse(get(url, :json, :json))
    end

    # JSON Styled RESTful POST
    def post_json(url, data)
      JSON.parse(post(url, data, :json, :json))
    end

    # JSON Styled RESTful PUT
    def put_json(url, data)
      JSON.parse(put(url, data, :json, :json))
    end

    # JSON Styled RESTful DELETE
    def delete_json(url)
      JSON.parse(delete(url, :json, :json))
    end

    # Build REST client that supports basic SSL with no cert verification (for use with private certs)
    def build_rest_client(url)
      RestClient::Resource.new(URI.encode(url), :verify_ssl => OpenSSL::SSL::VERIFY_NONE)
    end

    # RESTful GET request
    def get(url, content_type = :json, accept = :json)
      client = build_rest_client(url)
      client.get(:cookies => @cookie, :content_type => content_type, :accept => accept)
    rescue => e
      raise "GET Exception: Problem retrieving data (#{e.to_s})"
    end

    # RESTful POST request
    def post(url, data, content_type = :json, accept = :json)
      client = build_rest_client(url)
      client.post(data, :cookies => @cookie, :content_type => content_type, :accept => accept)
    rescue => e
      raise "POST Exception: Problem creating data (#{e.to_s})"
    end

    # RESTful PUT request
    def put(url, data, content_type = :json, accept = :json)
      client = build_rest_client(url)
      client.put(data, :cookies => @cookie, :content_type => content_type, :accept => accept)
    rescue => e
      raise "PUT Exception: Problem modifying data (#{e.to_s})"
    end

    # RESTful DELETE request
    def delete(url, content_type = :json, accept = :json)
      client = build_rest_client(url)
      client.delete(:cookies => @cookie, :content_type => content_type, :accept => accept)
    rescue => e
      raise "DELETE Exception: Problem removing data (#{e.to_s})"
    end
  end
end
