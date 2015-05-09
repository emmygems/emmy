require "rack"

module EmmyHttp
  class Application < ::Rack::Builder
    def initialize(app = nil, &block)
      super
    end

    def self.app(default_app = nil, &block)
      self.new(default_app, &block).to_app
    end
  end
end
