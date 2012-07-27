require 'jacha/version'
require 'jacha/connection_pool'

module Jacha
  def self.configure(name=nil)
    yield ConnectionPool.instance(name) if block_given?
  end
end
