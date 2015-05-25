# coding: utf-8
version = File.read(File.expand_path('../EMMY_VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = "emmy-le"
  spec.version       = version
  spec.authors       = ["inre"]
  spec.email         = ["inre.storm@gmail.com"]
  spec.summary       = %q{Emmy - EventMachine-based framework}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = ["README.md"]

  spec.required_ruby_version     = '>= 2.1.0'
  spec.required_rubygems_version = '>= 2.3.0'

  spec.add_dependency "eventmachine-le", "~> 1.1"
  spec.add_dependency "emmy-engine",  "~> 0.2"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rspec",   "~> 3.0"
  spec.add_development_dependency "rake",    "~> 10.0"
end
