require 'emmy_machine'
require 'emmy_http'

module Emmy
  extend self

  include EmmyMachine
  include EmmyHttp
end
