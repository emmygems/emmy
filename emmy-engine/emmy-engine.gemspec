# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'emmy/version'
version = File.read(File.expand_path('../../EMMY_VERSION', __FILE__)).strip
raise "Different version numbers" if version != Emmy::VERSION

Gem::Specification.new do |spec|
  spec.name          = "emmy-engine"
  spec.version       = Emmy::VERSION
  spec.authors       = ["inre"]
  spec.email         = ["inre.storm@gmail.com"]

  spec.summary       = %q{Emmy Engine}
  #spec.description   = %q{TODO: Write a longer description or delete this line.}
  #spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "emmy-machine", ">= 0.1.11"
  spec.add_dependency "emmy-http", ">= 0.2.2"
  spec.add_dependency "emmy-http-client", ">= 0.1.7"

  spec.add_development_dependency "eventmachine", ">= 1.0.7"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3"
end
