require 'singleton'
require 'jacha/connection'
require 'jacha/connection_spawner'

module Jacha
  class ConnectionPool
    include Singleton

    attr_accessor :jid,
                  :password,
                  :size,
                  :logger,
                  :retry_delay,
                  :connect_timeout

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
      pool.delete_if &:broken?
      if pool.size == 0
        sleep retry_delay
      end
      pool.sample
    end

    def spawn(options={})
      if options[:force]
        destroy
      else
        pool.delete_if &:broken?
      end
      ConnectionSpawner.fill self
    end

    def destroy
      pool.map &:destroy
      pool.clear
    end

    def fix_charset!
      require 'lib/jacha/xmpp_adapter/xmpp4r_monkeypatch'
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
