if RUBY_PLATFORM.include? 'java'
  require 'jacha/xmpp_adapter/smack'
else
  require 'jacha/xmpp_adapter/xmpp4r'
end

require 'forwardable'

module Jacha
  class Connection
    extend Forwardable

    SERVER_PING_DELAY = 59

    attr_reader :adapter,
                :pool,
                :logger

    delegate [ :connect!,
               :auth!,
               :present!,
               :stay_alive!,
               :destroy,
               :connected?,
               :broken?
             ] => :@adapter

    def initialize(jid, password, pool=nil)
      @pool = pool
      @adapter = ConnectionAdapter.new(jid, password)
      @adapter.on_exception do |ex|
        logger.warn "#{Time.now}: broken XmppConnection: #{self}: #{ex}"
        destroy
        @pool.respawn if @pool
      end
    end

    def online!
      connect!
      auth!
      present!
      stay_alive!

      self
    end

    def logger
      pool && pool.logger || (@logger ||= Logger.new(STDOUT))
    end
  end
end
