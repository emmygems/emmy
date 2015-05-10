# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_machine/version'

Gem::Specification.new do |spec|
  spec.name          = "emmy-machine"
  spec.version       = EmmyMachine::VERSION
  spec.authors       = ["inre"]
  spec.email         = ["inre.storm@gmail.com"]
  spec.summary       = %q{EventMachine with fibers}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fibre", "~> 0.9"

  spec.add_development_dependency "eventmachine", "~> 1.0"
  spec.add_development_dependency "bundler",      "~> 1.6"
  spec.add_development_dependency "rspec",        "~> 3.0"
  spec.add_development_dependency "rake",         "~> 10.0"
end
