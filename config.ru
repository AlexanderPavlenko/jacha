#!/usr/bin/env ruby
#\ -s trinidad
$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'jacha'
require 'jacha/server'

config = ::File.expand_path(ENV['JACHA_CONFIG'] || 'jacha_config.rb')
if ::File.exists?(config)
  load config
end

use Rack::ShowExceptions
run Jacha::Server.new
