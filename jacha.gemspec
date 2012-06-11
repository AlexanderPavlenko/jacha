# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jacha/version"

Gem::Specification.new do |s|
  s.name        = "jacha"
  s.version     = Jacha::VERSION
  s.authors     = ["AlexanderPavlenko"]
  s.email       = ["a.pavlenko@roundlake.ru"]
  s.homepage    = "http://github.com/roundlake/jacha"
  s.summary     = %q{Simple xmpp4r bot}
  s.description = %q{xmpp4r bot that can be included to project as well as started as a standalone service}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "xmpp4r"
end
