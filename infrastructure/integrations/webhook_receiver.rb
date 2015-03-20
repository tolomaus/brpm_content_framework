#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'rest-client'
require 'webrick'
require "#{File.dirname(__FILE__)}/../bootstrap"

Logger.initialize({ "log_file" => ENV["WEBHOOK_RECEIVER_LOG_FILE"] })

port = ENV["WEBHOOK_RECEIVER_PORT"]
mount_point = "/#{ENV["WEBHOOK_RECEIVER_MOUNT_POINT"]}"
process_event_script = ENV["WEBHOOK_RECEIVER_PROCESS_EVENT_SCRIPT"]

require process_event_script

class EventProcessor < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    begin
      event = JSON.parse(request.body)

      Logger.log "Processing new event..."
      process_event(event)

      response.status = 200
      response['Content-Type'] = "text/plain"
      response.body = "OK"
    rescue Exception => e
      Logger.log_error(e)
      Logger.log e.backtrace.join("\n\t")
    end
  end
end

begin
  server = WEBrick::HTTPServer.new(:Port => port)
  server.mount mount_point, EventProcessor

  trap("INT") {
    server.shutdown
  }

  Logger.log "Starting the server..."
  server.start
rescue Exception => e
  Logger.log_error(e)
  Logger.log e.backtrace.join("\n\t")

  raise e
end
