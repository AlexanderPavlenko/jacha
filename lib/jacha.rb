require 'jacha/version'
require 'jacha/connection_pool'

module Jacha
  def self.configure
    yield ConnectionPool.instance if block_given?
  end
end
