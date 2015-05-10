module Emmy
  class Runner
    include Singleton
    using EventObject
    events :parse

    RUBY     = Gem.ruby
    BIN_EMMY = "bin/emmy"

    attr_accessor :argv
    attr_accessor :env
    attr_accessor :config
    attr_accessor :action
    attr_accessor :option_parser

    def initialize
      @argv = ARGV
      @env  = ENV
      @config = EmmyHttp::Configuration.new
      @action = :start_server

      on :parse do
        parse_environment!(env)
      end
      on :parse do
        option_parser.parse!(argv)
      end
      on :parse do
        defaults!
      end
    end

    def execute_bin_emmy
      return false unless File.file?(BIN_EMMY)
      exec RUBY, BIN_EMMY, *argv
      true
    end

    def parse_environment!(env)
      config.environment = env['EMMY_ENV'] || env['RACK_ENV'] || 'development'
    end

    def option_parser
      @option_parser ||= OptionParser.new do |opts|
        opts.banner  = "Usage: emmy [options]"
        opts.separator "Options:"
        # configure
        opts.on("-e", "--environment ENV", "Specifies the execution environment",
                                          "Default: #{config.environment}") { |env| config.environment = env }
        opts.on("-p", "--port PORT",      "Runs Emmy on the specified port",
                                          "Default: #{config.url.port}")        { |port| config.url.port = port }
        opts.on("-a", "--address HOST",   "Binds Emmy to the specified host",
                                          "Default: #{config.url.host}")     { |address| config.url.host = address }
        opts.on("-b", "--backend [name]", "Backend name",
                                          "Default: backend")         { |name| config.backend = name }
        opts.on("-d", "--daemonize", "Runs server in the background") { config.daemonize = true }
        opts.on("-s", "--silence",   "Logging disabled")              { config.logging = false }
        # actions
        opts.on("-i", "--info",      "Shows server configuration") { @action = :show_configuration }
        opts.on("-c", "--console",   "Start a console")            { @action = :start_console }
        opts.on("-h", "--help",      "Display this help message")  { @action = :display_help }
        opts.on("-v", "--version",   "Display Emmy version.")      { @action = :display_version }
      end
    end

    def defaults!
      if Process.uid == 0
        config.user  = "worker"
        config.group = "worker"
      end

      config.pid ||= "tmp/pids/#{config.backend}.pid"
    end

    def run_action
      # Run parsers
      parse!
      # start action
      send(action)
      self
    end

    def start_server
      load backend_file
    end

    def start_console
      if defined?(binding.pry)
        TOPLEVEL_BINDING.pry
      else
        require 'irb'
        require 'irb/completion'
        IRB.start
      end
    end

    def show_configuration
      puts "Server configuration:"
      config.attributes.each do |name, value|
        value = "off" if value.nil?
        puts "  #{name}: #{value}"
      end
    end

    def display_help
      puts option_parser
    end

    def display_version
      puts Emmy::VERSION
    end

    private

    def backend_file
      [
        "#{Dir.getwd}/#{config.backend}.rb",
        "#{Dir.getwd}/config/#{config.backend}.rb",
        "emmy_http/server/backends/#{config.backend}.rb"
      ].each do |file|
        return file if File.readable_real?(file)
      end
      nil
    end

    #<<<
  end
end
