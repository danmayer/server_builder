# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'server_builder/version'

Gem::Specification.new do |spec|
  spec.name          = "server_builder"
  spec.version       = ServerBuilder::VERSION
  spec.authors       = ["Dan Mayer"]
  spec.email         = ["dan@mayerdan.com"]
  spec.description   = %q{Server builder is a small wrapper to help me boot up and build servers in a repeatable and verifiable way.}
  spec.summary       = %q{Server builder is a small wrapper to help me boot up and build servers in a repeatable and verifiable way}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry-byebug"
  spec.add_runtime_dependency 'simple-graphite'
  spec.add_runtime_dependency 'statsd-ruby'
  spec.add_runtime_dependency 'redis'
  spec.add_runtime_dependency 'logstash-logger'
  spec.add_runtime_dependency 'elasticsearch'
end
