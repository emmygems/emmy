# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_machine/version'

Gem::Specification.new do |spec|
  spec.name          = "emmy-machine"
  spec.version       = EmmyMachine::VERSION
  spec.authors       = ["Maksim V."]
  spec.email         = ["inre.storm@gmail.com"]
  spec.summary       = %q{Cover EventMachine with fiber's sugar}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version     = '>= 2.1.0'
  spec.required_rubygems_version = '>= 2.3.0'

  spec.add_dependency "fibre", "~> 1"
  spec.add_dependency "event_object", "~> 1"

  spec.add_development_dependency "eventmachine", "~> 1.0"
  spec.add_development_dependency "bundler",      "~> 1.12"
  spec.add_development_dependency "rspec",        "~> 3"
  spec.add_development_dependency "rake",         "~> 10"
end
