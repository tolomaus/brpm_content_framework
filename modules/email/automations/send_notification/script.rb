require "brpm/lib/brpm_rest_api"
require "framework/lib/request_params"
require 'mail'

def execute_script(params)
  smtp_server = params["SS_integration_dns"]
  smtp_server_address = smtp_server.split(":")[0]
  smtp_server_port = smtp_server.split(":")[1] || "25"
  username = params["SS_integration_username"]
  password = decrypt_string_with_prefix(params["SS_integration_password_enc"]) unless params["SS_integration_password_enc"].empty?
  from_address = params["SS_integration_details"]["from"]
  domain = params["SS_integration_details"]["domain"]

  options = {}
  options[:address] = smtp_server_address
  options[:port] = smtp_server_port
  options[:domain] = domain
  options[:enable_starttls_auto] = false
  unless password.empty?
    options[:user_name] = username
    options[:password] = password
    options[:authentication] = 'plain'
    options[:enable_starttls_auto] = true
  end

  Mail.defaults do
    delivery_method :smtp, options
  end

  recipient_first_name = params["recipient_name"].split(",").last.strip
  recipient_last_name = params["recipient_name"].split(",").first.strip
  user = get_user_by_name(recipient_first_name, recipient_last_name)
  recipient_email_address = user["email"]

  params = params.merge(get_request_params)
  subject = sub_tokens(params, params["subject"])
  body = sub_tokens(params, params["body"].gsub('\n', "\n"))

  Logger.log "Sending notification to #{user["first_name"]} #{user["last_name"]} '#{subject}' ..."
  Mail.deliver do
    to recipient_email_address
    from from_address
    subject subject
    body body
  end
end


