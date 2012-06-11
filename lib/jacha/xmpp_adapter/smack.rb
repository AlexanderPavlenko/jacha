require 'jacha/xmpp_adapter/smack.jar'
require 'java'

module Smack
  include_package 'org.jivesoftware.smack'
  module Packet
    include_package 'org.jivesoftware.smack.packet'
  end
end

module Jacha
  class ConnectionAdapter

    NAME = 'smack'

    attr_reader :client

    def initialize(jid, password)
      @password = password
      @username, @server = jid.split '@'
      config = Smack::ConnectionConfiguration.new @server
      config.setSendPresence false
      @client = Smack::XMPPConnection.new config

      exception_handler = lambda do |ex|
        unless broken?
          broken!
          if @on_exception
            @on_exception.call ex.toString
          end
        end
      end

      @connection_listener = (Class.new do
        include Smack::ConnectionListener

        def connectionClosed; end

        def connectionClosedOnError(ex)
          exception_handler.call ex
        end

        def reconnectingIn(seconds); end

        def reconnectionFailed(ex)
          exception_handler.call ex
        end

        def reconnectionSuccessful; end
      end).new
    end

    def connect!
      @client.connect
      @client.addConnectionListener @connection_listener

      self
    end

    def auth!
      @client.login @username, @password, Time.now.to_f.to_s

      self
    end

    def present!
      packet = Smack::Packet::Presence.new Smack::Packet::Presence::Type.available
      @client.sendPacket packet

      self
    end

    def ping_server!
      packet =  Smack::Packet::IQ.new
      packet.setType Smack::Packet::IQ::Type::GET
      packet.addExtension IQPingPacketExtensionImpl.new
      @client.sendPacket packet

      self
    end

    def stay_alive!
      unless @pinger && @pinger.alive?
        @pinger = Thread.new do
          while true
            if connected?
              ping_server!
              sleep Connection::SERVER_PING_DELAY
            else
              # Smack::ReconnectionManager should handle this case
            end
          end
        end
      end

      self
    end

    def subscribe_to!(jid)
      @client.getRoster.createEntry jid, jid
    end

    def online?(jid)
      @client.getRoster.getPresence(jid).isAvailable
    end

    def destroy
      broken!
      @pinger.kill if @pinger
      @client.disconnect if @client

      self
    end

    def connected?
      @client.isConnected
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

    class IQPingPacketExtensionImpl
      include Smack::Packet::PacketExtension

      def getElementName
        'ping'
      end

      def getNamespace()
        'urn:xmpp:ping'
      end

      def toXML()
        '<ping xmlns="urn:xmpp:ping"/>'
      end
    end
  end
end
