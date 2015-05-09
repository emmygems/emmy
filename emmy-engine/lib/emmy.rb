require 'emmy_machine'
require 'emmy_http'
require 'emmy_http/client'

module Emmy
  extend EmmyMachine::ClassMethods
  include EventObject
  include Fibre::Synchrony

  autoload :Http,   'emmy/http'
  autoload :Runner, 'emmy/runner'
end

require 'emmy/version'
