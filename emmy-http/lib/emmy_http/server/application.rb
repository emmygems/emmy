require "rack"

module EmmyHttp
  class Application < ::Rack::Builder
    attr_accessor :config

    def initialize(app = nil, &block)
      @config = Emmy::Runner.instance.config.clone
      super
    end

    def self.app(default_app = nil, &block)
      self.new(default_app, &block).to_app
    end

    def load(file)
      instance_eval(File.read(file), file)
    end

    def load_config
      config = Emmy::Runner.instance.config
      load "#{config.backend}/#{config.environment}.rb"
    end

    def configure(&b)
      instance_eval(&b)
    end
  end
end
