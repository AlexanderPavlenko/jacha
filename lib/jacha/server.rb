require 'logger'
require 'sinatra'

module Jacha
  class Server < Sinatra::Application

    def initialize
      super
      ConnectionPool.instance.spawn
    end

    get '/check' do
      client = ConnectionPool.instance.get_connection
      result = client.online? params['jid']
      "{result:#{!!result}}"
    end

    get '/subscribe_to' do
      client = ConnectionPool.instance.get_connection
      client.subscribe_to! params['jid']
      "{}"
    end
  end
end
