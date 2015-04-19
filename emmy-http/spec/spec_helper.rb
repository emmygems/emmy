require 'bundler/setup'
Bundler.setup

require File.expand_path("./lib/emmy_http")
require "emmy_machine"
require "fibre"

RSpec.configure do |config|
  config.color = true
end
