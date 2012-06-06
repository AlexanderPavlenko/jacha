module Jacha
  class ConnectionPool
    include Singleton

    attr_accessor :jid, :password, :size, :logger, :retry_delay, :connect_timeout

    def size
      @size ||= 3
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def retry_delay
      @retry_delay ||= 7
    end

    def connect_timeout
      @connect_timeout ||= 7
    end

    def pool
      @connections ||= []
    end

    def get_connection
      pool.sample
    end

    def spawn(number=nil)
      (number || size).times do
        logger.warn "#{Time.now}: Spawning XmppConnection"
        spawner = Thread.new do
          begin
            connection = Connection.new @jid, @password, self
            connection.connect!
            spawner[:connection] = connection
          rescue => ex
            logger.warn "#{Time.now}: Error on XmppConnection spawn: #{ex}"
          end
        end
        spawner.join connect_timeout
        connection = spawner[:connection]
        spawner.kill
        if connection && connection.connected?
          pool.push connection
          logger.warn "#{Time.now}: XmppConnection spawned: #{connection}"
        else
          logger.warn "#{Time.now}: XmppConnection spawn failed. Retrying in #{retry_delay} seconds."
          sleep retry_delay
          spawn 1
        end
      end
    end

    def respawn
      pool.delete_if &:broken?
      spawn size - pool.size
    end

    def destroy
      pool.map &:destroy
      pool.clear
    end

    def fix_charset!
      require_relative '../xmpp4r_monkeypatch'
    end

    def self.method_missing(sym, *args, &block)
      if instance.respond_to? sym
        instance.send(sym, *args, &block)
      else
        super
      end
    end
  end
end
