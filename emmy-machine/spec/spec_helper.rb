require 'bundler/setup'
Bundler.setup

require File.expand_path("./lib/emmy_machine")

RSpec.configure do |config|
  config.color = true
end
