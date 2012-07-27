require 'xmpp4r'
require 'xmpp4r/roster/helper/roster'

module Jacha
  class ConnectionAdapter

    NAME = 'xmpp4r'

    attr_reader :client

    def initialize(jid, password)
      @password = password
      @client = Jabber::Client.new "#{jid}/#{Time.now.to_f}"
      @client.on_exception do |ex|
        unless broken?
          broken!
          if @on_exception
            @on_exception.call ex
          end
        end
      end
    end

    def connect!
      @client.connect

      self
    end

    def auth!
      @client.auth @password
      @roster = Jabber::Roster::Helper.new @client
      @roster.wait_for_roster

      self
    end

    def present!
      packet = Jabber::Presence.new
      @client.send packet

      self
    end

    def ping_server!
      packet = Jabber::Iq.new :get
      extension = REXML::Element.new 'ping'
      extension.attributes['xmlns'] = 'urn:xmpp:ping'
      packet.query = extension
      @client.send packet

      self
    end

    def stay_alive!
      unless @pinger && @pinger.alive?
        @pinger = Thread.new do
          while true
            sleep Connection::SERVER_PING_DELAY
            if connected?
              ping_server!
            else
              connect!
            end
          end
        end
      end

      self
    end

    def subscribe_to!(jid)
      @roster.add jid, jid, true
    end

    def online?(jid)
      @roster[jid] && @roster[jid].online?
    end

    def destroy
      broken!
      @pinger.kill if @pinger
      @client.close if @client

      self
    end

    def connected?
      @client.is_connected?
    end

    def broken?
      @broken
    end

    def on_exception(&block)
      @on_exception = block

      self
    end

  protected

    def broken!
      @broken = true
    end
  end
end
