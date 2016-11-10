# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_http/version'

version = File.read(File.expand_path('../../EMMY_VERSION', __FILE__)).strip
if version != EmmyHttp::VERSION
  puts "Different version numbers"
  exit
end

Gem::Specification.new do |spec|
  spec.name          = "emmy-http"
  spec.version       = EmmyHttp::VERSION
  spec.authors       = ["Maksim V."]
  spec.email         = ["inre.storm@gmail.com"]
  spec.summary       = %q{Ruby HTTP interface}
  spec.description   = spec.summary
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "event_object",   "~> 1"
  spec.add_dependency "emmy-machine",   "~> 0.2"
  spec.add_dependency "fibre",          "~> 1"
  spec.add_dependency "util_pack",      "~> 0.1"
  spec.add_dependency "model_pack",     "~> 1"
  spec.add_dependency "addressable",    "~> 2.5"

  spec.add_development_dependency "eventmachine", "~> 1.0"
  spec.add_development_dependency "bundler",      "~> 1.12"
  spec.add_development_dependency "rake",         "~> 10"
  spec.add_development_dependency "rspec",        "~> 3"
end
