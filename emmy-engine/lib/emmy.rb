require 'emmy_machine'
require 'emmy_http'

module Emmy
  include EmmyMachine
  include EmmyHttp
  extend self
end
