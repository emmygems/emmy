require 'optparse'

module Emmy
  class Runner
    include Singleton
    using EventObject
    events :init, :parse

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
        parse_environment!
      end
      on :parse do
        option_parser.parse!(argv)
      end
      on :parse do
        defaults!
      end
      on :parse do
        update_rack_environment!
      end
      on :init do
        initialize!
      end
    end

    def execute_bin_emmy
      return false unless File.file?(BIN_EMMY)
      exec RUBY, BIN_EMMY, *argv
      true
    end

    def parse_environment!
      config.environment = env['EMMY_ENV'] || env['RACK_ENV'] || 'development'
    end

    def update_rack_environment!
      ENV['RACK_ENV'] = config.environment
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
        opts.on("-b", "--backend NAME",   "Backend name",
                                          "Default: backend")         { |name| config.backend = name }
        opts.on("-d", "--daemonize",   "Runs server in the background") { @action = :daemonize_server }
        opts.on("-s", "--servers NUM", "Number of servers to start")    { |num| @action = :daemonize_server; config.servers = num.to_i; }
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

      if config.environment == "development"
        config.stdout = "#{config.backend}.stdout"
        config.stderr = config.stdout
      end
    end

    def initialize!
      if config.servers > 1
        config.url.port += config.id
        config.pid   = "#{config.backend}#{config.id}.pid"
        config.log   = "#{config.backend}#{config.id}.log"
      else
        config.pid   = "#{config.backend}.pid"
        config.log   = "#{config.backend}.log"
      end
    end

    def run_action
      # Run parsers
      parse!
      # start action
      send(action)
      self
    end

    def daemonize_server
      run_next_instance
    end

    def run_next_instance
      if config.id >= config.servers
        exit
      end

      Process.fork do
        Process.setsid
        if fork
          config.id += 1
          run_next_instance
        end

        Fibre.reset
        # can load configuration
        init.fire_for(self)

        scope_pid(Process.pid) do |pid|
          puts pid
          File.umask(0000)
          bind_standard_streams
          run
        end
      end
    end

    def start_server
      init.fire_for(self)
      run
    end

    def run
      Emmy.run do
        trap("INT")  { Emmy.stop }
        trap("TERM") { Emmy.stop }

        Emmy.fiber_block do
          Backend.module_eval(File.read(backend_file), backend_file)
        end
      end
    end

    def start_console
      EmmyMachine.run_block do
        if defined?(binding.pry)
          TOPLEVEL_BINDING.pry
        else
          require 'irb'
          require 'irb/completion'

          IRB.start
        end
      end
    end

    def show_configuration
      init.fire_for(self)
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

    def error(message)
      puts message
      exit
    end

    def configure(&b)
      on :init, &b
    end

    private

    def backend_file
      thin = (config.backend == 'backend') ? EmmyExtends::Thin::EMMY_BACKEND : nil rescue nil
      backends = [
        "#{Dir.getwd}/#{config.backend}.em",
        "#{Dir.getwd}/config/#{config.backend}.em",
        thin
      ].compact

      backends.each do |file|
        return file if File.readable_real?(file)
      end
      error "Can't find backend in #{backends.inspect} places."
    end

    def scope_pid(pid)
      FileUtils.mkdir_p(File.dirname(config.pid))
      stop_pid(File.read(config.pid).to_i) if File.exists?(config.pid)
      File.open(config.pid, 'w') { |f| f.write(pid) }
      if block_given?
        yield pid
        delete_pid
      end
    end

    def stop_pid(pid)
      unless pid.zero?
        Process.kill("TERM", pid)
        puts "Restarting..."
        while File.exists?(config.pid)
          sleep(0.1)
        end
        #Process.wait(pid)
      end
    rescue
    end

    def delete_pid
      File.delete(config.pid)
    end

    def bind_standard_streams
      STDIN.reopen("/dev/null")
      STDOUT.reopen(config.stdout, "a")

      if config.stdout == config.stderr
        STDERR.reopen(STDOUT)
      else
        STDERR.reopen(config.stderr, "a")
      end
    end

    #<<<
  end
end
