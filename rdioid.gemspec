# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rdioid/version'

Gem::Specification.new do |spec|
  spec.name          = "rdioid"
  spec.version       = Rdioid::VERSION
  spec.authors       = ["Brent Redd"]
  spec.email         = ["reddshack@gmail.com"]

  spec.summary       = %q{Simple Rdio Web Service API wrapper with OAuth 2.0}
  spec.description   = %q{Handles OAuth 2.0 authentication and API calls for Rdio Web Service API.}
  spec.homepage      = "https://github.com/reddshack/rdioid"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httpclient", "~> 2.6.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
