require 'singleton'
require 'emmy_machine'
require 'emmy_http'
require 'emmy_http/client'

module Emmy
  extend EmmyMachine::ClassMethods
  include EventObject
  include Fibre::Synchrony

  autoload :Http,    'emmy/http'
  autoload :Backend, 'emmy/backend'
  autoload :Runner,  'emmy/runner'

  module_function

  def env
    Emmy::Runner.instance.config.environment
  end
end

require 'emmy/version'
