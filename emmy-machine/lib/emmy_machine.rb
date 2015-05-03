require "fibre"
require "eventmachine"
require "uri"

require "emmy_machine/version"
require "emmy_machine/connection"
require "emmy_machine/class_methods"

module EmmyMachine
  include ClassMethods
  extend ClassMethods
end
