#!/usr/bin/env ruby
$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'jacha'
require 'jacha/server'

config = ::File.expand_path(ENV['JACHACONFIG'] || 'jacha.rb')
if ::File.exists?(config)
  load config
end

use Rack::ShowExceptions
run Jacha::Server.new
