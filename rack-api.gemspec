# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rack/api"

Gem::Specification.new do |s|
  s.name        = "rack-api"
  s.version     = Rack::API::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/rack-api"
  s.summary     = "Create web app APIs that respond to one or more formats using an elegant DSL."
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rack", "~> 1.2.1"
  s.add_dependency "rack-mount", "~> 0.6.14"
  s.add_dependency "activesupport", "~> 3.0.6"
  s.add_development_dependency "rspec", "~> 2.5.0"
  s.add_development_dependency "rack-test", "~> 0.5.7"
  s.add_development_dependency "redis", "~> 2.2.0"
  s.add_development_dependency "ruby-debug19" if RUBY_VERSION >= "1.9"
end
