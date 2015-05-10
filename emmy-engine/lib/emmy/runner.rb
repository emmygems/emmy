module Emmy
  class Runner
    include Singleton
    using EventObject
    events :parse

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
        options_parser.parse!(arguments)
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

    def parse_environment(env)
      config.environment = env['EMMY_ENV'] || env['RACK_ENV'] || 'development'
    end

    def option_parser(arguments)
      @option_parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: emmy [options]"
        # configure
        opts.on("-e", "--environment ENV", "Specifies the execution environment",
                                          "Default: #{server.environment}") { |env| config.environment = env }
        opts.on("-p", "--port PORT",      "Runs Emmy on the specified port.",
                                          "Default: #{server.port}")        { |port| config.port = port }
        opts.on("-a", "--address HOST",   "Binds Emmy to the specified host",
                                          "Default: #{config.address}")  { |address| config.address = address }
        opts.on("-b", "--backend [name]", "Backend name",
                                          "Default: backend") { |name| config.backend = name }
        opts.on("-d", "--daemonize", "Runs server in the background") { config.daemonize = true }
        opts.on("-s", "--silence",   "Logging disabled") { config.logging = false }
        # actions
        opts.on("-i", "--info",      "Shows server config")       { @action = :show_configuration }
        opts.on("-c", "--console",   "Start a console")           { @action = :start_console }
        opts.on("-h", "--help",      "Display this help message") { @action = :display_help }
        opts.on("-v", "--version",   "Display Emmy version.")     { @action = :display_verson }
      end
    end

    def defaults!
      if socket
        self.address = nil
        self.port    = nil
      end

      if Process.uid == 0
        self.user  = "worker"
        self.group = "worker"
      end

      self.pid ||= "tmp/pids/#{backend}.pid"
    end

    def run_action
      # Run parsers
      parse!
      # start action
      send(action)
      self
    end

    def start_server

    end

    def start_console
      if defined?(binding.pry)
        TOPLEVEL_BINDING.pry
      else
        IRB.start
      end
    end

    def show_configuration
      
    end

    def display_help
      puts option_parser
      exit
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
    end

    #<<<
  end
end
