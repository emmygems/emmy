require "rack"

module EmmyHttp
  class Application < ::Rack::Builder
    attr_accessor :config
    attr_accessor :server

    def initialize(app = nil, &block)
      @config = if Emmy.const_defined?(:Runner)
         Emmy::Runner.instance.config.copy
      else
        EmmyHttp::Configuration.new
      end

      super
    end

    def self.app(default_app = nil, &block)
      self.new(default_app, &block).to_app
    end

    def configure(&b)
      instance_eval(&b)
    end
    
    def server
      @server ||= config.adapter.new(config, self)
    end

    def to_a
      server.to_a
    end
  end
end
