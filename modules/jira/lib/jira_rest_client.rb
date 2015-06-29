require 'json'
require 'uri'

#=============================================================================#
# Jira Rest Module                                                            #
#-----------------------------------------------------------------------------#
# The REST module currently supports the 6.0.8 version of the Jira API as     #
# well as a rest client which supports both HTTP and HTTPS                    #
#=============================================================================#

class JiraRestClient
  def initialize(integration_settings = BrpmAuto.integration_settings)
    @url = integration_settings.dns
    @username = integration_settings.username
    @password = integration_settings.password

    @api_url = "#{@url}/rest/api/2"
  end

  # POST /rest/api/2/issue/{issueIdOrKey}/comment
  def add_comment(issue_id, comment_body = 'Dummy Comment')
    cmmnt = {:body => comment_body}
    Rest.post("#{@api_url}/issue/#{issue_id}/comment", cmmnt, { :username => @username, :password => @password })["response"]
  end

  # GET /rest/api/2/issue/{issueIdOrKey}/transitions[?expand=transitions.fields]
  def get_issue_transitions(issue_id, expand_transition = false)
    url = "#{@api_url}/issue/#{issue_id}/transitions"
    if expand_transition
      url = "#{url}?expand=transitions.fields"
    end
    Rest.get(url, { :username => @username, :password => @password })["response"]
  end

  # GET /rest/api/2/issue/{issueIdOrKey}/transitions?transitionId={transistion_id}[&expand=transitions.fields]
  def get_issue_transition(issue_id, transition_id, expand_transition = false)
    url = "#{@api_url}/issue/#{issue_id}/transitions?transitionId=#{transition_id}"
    if expand_transition
        url = "#{url}&expand=transitions.fields"
    end
    Rest.get(url, { :username => @username, :password => @password })["response"]
  end

  # POST /rest/api/2/issue/{issueIdOrKey}/transitions[?expand=transitions.fields]
  def post_issue_transition(issue_id, transition_id, comment = 'simple comment', expand_transition = false)
    url = "#{@api_url}/issue/#{issue_id}/transitions"
    if expand_transition
      url = "#{url}?expand=transitions.fields"
    end
    transition = {:update=>{:comment =>[{:add => {:body => "#{comment}"}}]}, :transition => {:id => "#{transition_id}"}}
    #Simple post as only return code is returned
    Rest.post(url, transition, { :username => @username, :password => @password })["response"]
  end

  # GET /rest/api/2/project
  def get_projects()
    Rest.get("#{@api_url}/project", { :username => @username, :password => @password })["response"]
  end

  def set_issue_to_status(issue_id, status)
    BrpmAuto.log "Getting the possible transitions for issue #{issue_id}..."
    result = get_issue_transitions(issue_id)
    transitions = result["transitions"]

    transition = transitions.find { |transition| transition["to"]["name"] == status }

    if transition
      BrpmAuto.log "Issuing transition #{transition["name"]} to update the status of the issue to #{status}..."
      issues = post_issue_transition(issue_id, transition["id"])
    else
      BrpmAuto.log "This ticket does not have a transition to status #{status} currently. Leaving it in its current state."
    end
  end

  # GET /rest/api/2/search?jql=[Some Jira Query Language Search][&startAt=<num>&maxResults=<num>&fields=<field,field,...>&expand=<param,param,...>]
  def search(jql, start_at = 0, max_results = 50, fields = '', expand = '')
    url = "#{@api_url}/search?jql=#{jql}"
    url = "#{url}&startAt=#{start_at}" unless start_at == 0
    url = "#{url}&maxResults=#{max_results}" unless max_results == 50
    url = "#{url}&fields=#{fields}" unless fields == ''
    url = "#{url}&expand=#{expand}" unless expand == ''

    Rest.get(url, { :username => @username, :password => @password })["response"]
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
    Rest.get(url, { :username => @username, :password => @password })["response"]
  end

  def get_option_for_dropdown_custom_field(custom_field_id, option_value)
    # NOTE: this method assumes that the "Customfield Editor Plugin" is installed on the JIRA instance and that permission was granted for the custom field

    url = "#{@url}/rest/jiracustomfieldeditorplugin/1.1/user/customfieldoptions/customfield_#{custom_field_id}"
    result = Rest.get(url, { :username => @username, :password => @password })

    if result["status"] == "success"
      custom_field_options = result["response"]
      return custom_field_options.find { |custom_field_option| custom_field_option["optionvalue"] == option_value }
    else
      if result["code"] == 404
        return nil
      else
        raise "Error getting option: #{result["error_message"]}"
      end
    end
  end

  def create_option_for_dropdown_custom_field(custom_field_id, option_value)
    # NOTE: this method assumes that the "Customfield Editor Plugin" is installed on the JIRA instance and that permission was granted for the custom field

    custom_field_option = get_option_for_dropdown_custom_field(custom_field_id, option_value)

    if custom_field_option
      BrpmAuto.log "The option already exists, nothing to do."
      return custom_field_option
    end

    url = "#{@url}/rest/jiracustomfieldeditorplugin/1.1/user/customfieldoption/customfield_#{custom_field_id}"
    data = {:optionvalue => option_value }

    result = Rest.post(url, data, { :username => @username, :password => @password })

    if result["status"] == "success"
      return result["response"]
    else
      raise "Could not create option: #{result["error_message"]}"
    end
  end

  def update_option_for_dropdown_custom_field(custom_field_id, old_option_value, new_option_value)
    # NOTE: this method assumes that the "Customfield Editor Plugin" is installed on the JIRA instance and that permission was granted for the custom field

    custom_field_option_to_update = get_option_for_dropdown_custom_field(custom_field_id, old_option_value)

    if custom_field_option_to_update
      url = "#{@url}/rest/jiracustomfieldeditorplugin/1.1/user/customfieldoption/customfield_#{custom_field_id}/#{custom_field_option_to_update["id"]}"
      data = {:optionvalue => new_option_value }

      result = Rest.put(url, data, { :username => @username, :password => @password })

      if result["status"] == "success"
        return result["response"]
      else
        raise "Could not update option: #{result["error_message"]}"
      end
    else
      BrpmAuto.log "The option doesn't exist yet, creating it instead of updating..."
      create_option_for_dropdown_custom_field(custom_field_id, new_option_value)
    end
  end

  def delete_option_for_dropdown_custom_field(custom_field_id, option_value)
    # NOTE: this method assumes that the "Customfield Editor Plugin" is installed on the JIRA instance and that permission was granted for the custom field

    custom_field_option_to_delete = get_option_for_dropdown_custom_field(custom_field_id, option_value)

    if custom_field_option_to_delete
      url = "#{@url}/rest/jiracustomfieldeditorplugin/1.1/user/customfieldoption/customfield_#{custom_field_id}/#{custom_field_option_to_delete["id"]}"

      result = Rest.delete(url, { :username => @username, :password => @password })

      if result["status"] == "success"
        return result["response"]
      else
        raise "Could not delete option: #{result["error_message"]}"
      end
    else
      BrpmAuto.log "The option doesn't exist, nothing to do."
    end
  end
end
