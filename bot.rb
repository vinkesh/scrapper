require 'rubygems'  
require 'xmpp4r'
require 'xmpp4r/roster' 
require 'eventmachine'
# require 'job_portal.rb'
# require 'active_record'   
# require 'schema'


class Bot
  ID = "someid@gmail.com"
  PASSWORD = "password"
  
  attr_reader :client
  
  def initialize
    @client = Jabber::Client.new(Jabber::JID::new(ID))
    @client.connect('talk.google.com', 5222)
    @client.auth(PASSWORD)
    @client.send(Jabber::Presence.new.set_type(:available))
    @roster = Jabber::Roster::Helper.new(@client)
    @matchers = []
    @matchers << help
  end

  def listen
    puts "Started listening.. "
    EM::run do
      t1 = Thread.new do
        handle_received_messages
      end
      t1.abort_on_exception = true

      t2 = Thread.new do
        handle_subscription_request
      end
      t2.abort_on_exception = true
      
      EM::PeriodicTimer.new(10) do
        @client.send(Jabber::Presence.new.set_type(:available))
      end

      t1.join
      t2.join
    end
  end
  
  def handle_received_messages 
    begin
      @client.add_message_callback do |m|
        if m.type != :error
          @matchers.each do |matcher| 
            matcher.handle(m, @client)
          end
        else
          puts "error in message"
        end
      end
    rescue => e
      puts e
    end
  end
  
  def handle_subscription_request
    begin
      @roster.add_subscription_request_callback do |item,pres| 
        #we accept everyone 
        p "got something from #{pres.from}"
        if pres.from.to_s.match(/@thougtworks\.com/i)
          @roster.accept_subscription(pres.from.to_s.gsub(/\/.*/, ""))
          puts "Accepting invitation::"
          #Now it's our turn to send a subscription request
          x = Jabber::Presence.new.set_type(:subscribe).set_to(pres.from.to_s.gsub(/\/.*/, ""))
          @client.send(x)

          #let's greet our new user
          m=Jabber::Message::new
          m.to = pres.from.to_s.gsub(/\/.*/, "")
          m.body = "Welcome! Type Help to get all valid options"
          @client.send(m)
          puts "sent welcome message"
        end
      end  
    rescue => e
      puts "error :: #{e}"
    end
  end
  
  def add_matcher(message_parser)
    @matchers << message_parser
  end
  
  def help
    help_match = Proc.new{|message| message.body.match(/help/i) ? true : false}
    help_handler = Proc.new do |message, client| 
      begin
        reply = @matchers.map{|matcher| "\n*#{matcher.usage}* :: _#{matcher.info}_"}.join("")
        puts "From :: #{message.from} ..."
        msg = Jabber::Message.new(message.from.to_s.gsub(/\/.*/, ""), reply)
        msg.type = :chat
        client.send(msg)
      rescue => e
        puts "Error :: #{e}"
      end
    end
    MessageParser.new(help_match, help_handler, "help", "print this information")
  end
end

class MessageParser

  attr_reader :usage, :info
  def initialize(matching_exp, handler, usage = nil, info = nil)
    @exp_match = matching_exp
    @handler = handler
    @usage = usage || ""
    @info = info || ""
  end
  
  def handle(message, client)
    @handler.call(message, client) if @exp_match.call(message) 
  end
end

# class Worker
#   include EM::Deferrable
# 
#   def heavy_lifting
#     30.times do |i|
#       puts "Lifted #{i}"
#       sleep 0.1
#     end
#     set_deferred_status :succeeded
#   end
# end
# 
