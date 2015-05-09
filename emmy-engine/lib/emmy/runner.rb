module Emmy
  class Runner
    attr_accessor :settings

    def initialize(arguments=[])
      @settings = EmmyHttp::Settings.new
      options_parser.parse!(arguments)
    end

    def option_parser(arguments)
      OptionParser.new do |opts|
        opts.banner = "Usage: emmy [options]"
        opts.on("-e", "--environment ENV",  "Specifies the execution environment",
                                      "Default: #{server.environment}") { |env| settings.environment = env }
        opts.on("-p", "--port PORT",  "Runs Emmy on the specified port.",
                                      "Default: #{server.port}")        { |port| settings.port = port }
        opts.on("-a", "--address HOST", "Binds Emmy to the specified host",
                                        "Default: #{settings.address}")  { |address| settings.address = address }
        opts.on("-b", "--backend [name]", "Backend ",
                                        "Default: /config/[name].rb") { |file| settings.config = file }
        opts.on("-d", "--daemonize", "Runs server in the background")    { settings.daemonize = true }
        opts.on("-c", "--console",   "Start a console")       { settings.console = true }
        opts.on("-i", "--info",      "Shows server settings") { show_settings }
        opts.on("-s", "--silence",   "Logging disabled")      { settings.logging = false }
        opts.on("-h", "--help",      "Display this help message") { display_help(opts) }
        opts.on("-v", "--version",   "Display Emmy version.")     { display_verson }
      end
    end

    def run!

    end

    def display_help
      puts opts
      exit
    end

    def display_version
      puts Emmy::VERSION
    end

    #<<<
  end
end
