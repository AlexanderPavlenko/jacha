require 'logger'
require 'sinatra'
require 'trinidad'

module Jacha
  class Server < Sinatra::Application

    def initialize
      super
      ConnectionPool.instance.spawn
    end

    get '/check' do
      checker = ConnectionPool.instance.get_connection
      result = checker.online? params['jid']
      "#{!!result}"
    end
  end
end
