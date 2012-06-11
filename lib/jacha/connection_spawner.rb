require 'thread'

module Jacha
  class ConnectionSpawner

    def self.fill(connection_pool)
      number = connection_pool.size - connection_pool.pool.size
      for i in number.times
        connection_pool.logger.warn "#{Time.now}: Spawning XmppConnection"
        spawner = Thread.new do
          begin
            connection = Connection.new connection_pool.jid, connection_pool.password, connection_pool
            connection.online!
            spawner[:connection] = connection
          rescue => ex
            connection_pool.logger.warn "#{Time.now}: Error on XmppConnection spawn: #{ex}"
          end
        end
        spawner.join connection_pool.connect_timeout
        connection = spawner[:connection]
        spawner.kill
        if connection && connection.connected?
          connection_pool.pool.push connection
          connection_pool.logger.warn "#{Time.now}: XmppConnection spawned: #{connection}"
        else
          connection_pool.logger.warn "#{Time.now}: XmppConnection spawn failed. Retrying in #{connection_pool.retry_delay} seconds."
          sleep connection_pool.retry_delay
          redo
        end
      end
    end
  end
end
