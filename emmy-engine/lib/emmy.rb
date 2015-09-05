require 'singleton'
require 'emmy_machine'
require 'emmy_http'
require 'emmy_http/client'
require 'emmy_http/server'

module Emmy
  extend EmmyMachine::ClassMethods
  include EventObject
  include Fibre::Synchrony

  autoload :Http,    'emmy/http'
  autoload :Backend, 'emmy/backend'
  autoload :Runner,  'emmy/runner'

  module_function

  def env
    env.config.environment
  end

  def runner
    Emmy::Runner.instance
  end
end

require 'emmy/version'
