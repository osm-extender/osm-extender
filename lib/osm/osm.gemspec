# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.join(File.dirname(__FILE__), 'version')

Gem::Specification.new do |s|
  s.name        = "osm"
  s.version     = Osm::VERSION
  s.authors     = ['Robert Gauld']
  s.email       = ['robert@robertgauld.co.uk']
  s.homepage    = ''
  s.summary     = %q{Use the Online Scout Manager API}
  s.description = %q{Use the Online Scout Manager API (https://www.onlinescoutmanager.co.uk) to retrieve and save data.}

  s.rubyforge_project = "osm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'httparty'   # Used to make web requests to the API

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fakeweb'

end
