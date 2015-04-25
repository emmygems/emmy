# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_http/version'

Gem::Specification.new do |spec|
  spec.name          = "emmy-http"
  spec.version       = EmmyHttp::VERSION
  spec.authors       = ["inre"]
  spec.email         = ["inre.storm@gmail.com"]
  spec.summary       = %q{EmmyHttp - EventMachine's HTTP Client}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "event_object", "~> 0.9.1"
  spec.add_dependency "emmy-machine", "~> 0.1.8"
  spec.add_dependency "fibre", "~> 0.9.3"
  spec.add_dependency "util_pack", "~> 0.1"
  spec.add_dependency "model_pack", "~> 0.9.6"
  spec.add_dependency "addressable", ">= 2.3.8"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3"
end
