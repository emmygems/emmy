require 'emmy_machine'
require 'emmy_http'
require 'emmy_http/client'

module Emmy
  extend EmmyMachine::ClassMethods

  autoload :Http, 'emmy/http'  
end
