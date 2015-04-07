#!/usr/bin/env jruby
require 'rubygems'
require 'torquebox'
require 'torquebox-messaging'
require 'xmlsimple'
require "#{File.dirname(__FILE__)}/../../modules/framework/bootstrap"

Logger.initialize({ "log_file" => ENV["EVENT_HANDLER_LOG_FILE"] })

host = ENV["EVENT_HANDLER_BRPM_HOST"]
port = ENV["EVENT_HANDLER_MESSAGING_PORT"]
username = ENV["EVENT_HANDLER_MESSAGING_USERNAME"]
password = ENV["EVENT_HANDLER_MESSAGING_PASSWORD"]
process_event_script = ENV["EVENT_HANDLER_PROCESS_EVENT_SCRIPT"]

require "#{File.dirname(__FILE__)}/../../#{process_event_script}"

class MessagingProcessor < TorqueBox::Messaging::MessageProcessor

  MESSAGING_PATH = '/topics/messaging/brpm_event_queue'

  def initialize(host, port, username, password)
    Logger.log "Initializing the message processor..."
    @destination = TorqueBox::Messaging::Topic.new(
        MESSAGING_PATH,
        :host => host,
        :port => port,
        :username => username,
        :password => password
    )
  end

  def run
    begin
      xml = "<root>#{@destination.receive}</root>"
      Logger.log xml if ENV["EVENT_HANDLER_LOG_EVENT"]=="1"

      event = XmlSimple.xml_in(xml)

      Logger.log "Processing new event..."
      process_event(event)

    rescue Exception => e
      Logger.log_error(e)
      Logger.log e.backtrace.join("\n\t")
    end
  end
end

begin
  consumer = MessagingProcessor.new(host, port, username, password)
  Logger.log "Starting to listen for events ..."
  loop do
    consumer.run
  end

rescue Exception => e
  Logger.log_error(e)
  Logger.log e.backtrace.join("\n\t")

  raise e
end
