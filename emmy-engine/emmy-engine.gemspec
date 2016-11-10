# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy/version'

version = File.read(File.expand_path('../../EMMY_VERSION', __FILE__)).strip
if version != Emmy::VERSION
  puts 'Emmy Engine gem has the different version than Emmy gem has. (expect #{Emmy::VERSION}, current #{version})'
  exit
end

Gem::Specification.new do |spec|
  spec.name          = 'emmy-engine'
  spec.version       = Emmy::VERSION
  spec.summary       = %q{Console interface for Emmy}
  spec.description   = %q{Support commands: start/stop server, display configuration, run console}
  spec.license       = "MIT"

  spec.authors       = ['Maksim V.']
  spec.email         = ['inre.storm@gmail.com']
  spec.homepage      = 'https://github.com/emmygems'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = 'emmy'
  spec.require_paths = ['lib']

  spec.required_ruby_version     = '>= 2.2.2'
  spec.required_rubygems_version = '>= 2.3.0'

  spec.add_dependency 'emmy-machine', '~> 0.4'
  spec.add_dependency 'emmy-http', '~> 0.4'
  spec.add_dependency 'emmy-http-client', '~> 0.2'
  spec.add_dependency 'emmy-http-server', '~> 0.2'

  spec.add_development_dependency 'eventmachine', '~> 1'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
end
