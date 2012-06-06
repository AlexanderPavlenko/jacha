require 'xmpp4r'

module Jacha
  class Connection

    attr_reader :jabber, :pool

    def initialize(jid, password, pool=nil)
      @password = password
      @jabber = Jabber::Client.new "#{jid}/#{Time.now.to_f}"
      @pool = pool
      @jabber.on_exception do |ex, stream, place|
        unless broken?
          broken!
          logger.warn "#{Time.now}: broken XmppConnection: #{self}: #{ex} at #{place}"
          destroy
          @pool.respawn if @pool
        end
      end
    end

    def connect!
      jabber_connect!
      @pinger = Thread.new do
        while true
          if connected?
            sleep 180
            online!
          else
            jabber_connect!
          end
        end
      end
      online!
    end

    def online!(&block)
      packet = Jabber::Presence.new
      packet.from = @jabber.jid
      @jabber.send packet, &block
    end

    def connected?
      @jabber.is_connected?
    end

    def online?(jid, timeout=1.5)
      # Only works if our bot is authorized by the given JID
      # see Presence with type :subscribe for more details
      # Also, bot should be online by itself
      jid = Jabber::JID.new(jid)
      pinger = Thread.new do
        pinger[:online] = nil
        packet = Jabber::Presence.new
        packet.to = jid
        packet.from = @jabber.jid
        packet.type = :probe
        @jabber.send(packet) do |presence|
          from = Jabber::JID.new presence.from
          if from.node == jid.node && from.domain == jid.domain
            if presence.type.nil?
              pinger[:online] = true
              pinger.stop
            elsif presence.type == :error
              pinger.stop
            end
          end
        end
      end
      pinger.join timeout
      result = pinger[:online]
      pinger.kill
      result
    end

    def destroy
      broken!
      @pinger.kill if @pinger
      @jabber.close if @jabber
    end

    def broken!
      @broken = true
    end

    def broken?
      @broken
    end

    def logger
      @pool && @pool.logger || (@logger ||= Logger.new(STDOUT))
    end

    def jabber_connect!
      @jabber.connect
      @jabber.auth @password
    end
  end
end
