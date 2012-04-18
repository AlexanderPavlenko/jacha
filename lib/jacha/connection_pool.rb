module Jacha
  class ConnectionPool
    include Singleton

    attr_accessor :jid, :password, :size, :logger

    def pool
      @connections ||= []
    end

    def size
      @size ||= 3
    end

    def logger
      @logger ||= Logger.new(STDOUT)
    end

    def get_connection
      pool.sample
    end

    def spawn(number=nil)
      (number || size).times do
        logger.warn "#{Time.now}: Spawning XmppConnection"
        spawner = Thread.new do
          begin
            connection = Connection.new @jid, @password
            spawner[:connection] = connection
          rescue => ex
            logger.warn "#{Time.now}: Error on XmppConnection spawn: #{ex}"
          end
        end
        spawner.join 7
        connection = spawner[:connection]
        spawner.kill
        if connection && connection.connected?
          connection.pool = self
          pool << connection
          logger.warn "#{Time.now}: XmppConnection spawned: #{connection}"
        else
          logger.warn "#{Time.now}: XmppConnection spawn failed. Retrying in 7 seconds."
          sleep 7
          spawn 1
        end
      end
    end

    def respawn
      pool.delete_if &:marked?
      spawn @size - pool.size
    end

    def destroy
      pool.map &:destroy
      pool.clear
    end

    def fix_charset!
      require_relative '../xmpp4r_monkeypatch'
    end
  end
end
