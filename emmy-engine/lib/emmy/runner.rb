require 'optparse'

module Emmy
  class Runner
    include Singleton
    using EventObject
    events :bootstrap, :instance

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

      on :bootstrap do
        parse_environment!
      end
      on :bootstrap do
        option_parser.parse!(argv)
      end
      on :bootstrap do
        defaults!
      end
      on :bootstrap do
        update_rack_environment!
      end
      on :instance do |id|
        instance_defaults!(id)
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
                                          "Default: #{config.url.port}")    { |port| config.url.port = port }
        opts.on("-a", "--address HOST",   "Binds Emmy to the specified host",
                                          "Default: #{config.url.host}")    { |address| config.url.host = address }
        opts.on("-b", "--backend NAME",   "Backend name",
                                          "Default: backend")           { |name| config.backend = name }
        opts.on("-d", "--daemonize",   "Runs server in the background") { @action = :daemonize_server }
        opts.on("-s", "--servers NUM", "Number of servers to start") do |num|
          @action = :daemonize_server if @action == :start_server
          config.servers = num.to_i
        end
        opts.on('', '--id NUM',    "Server identifier")         { |id| config.id = id.to_i }
        opts.on('', '--pre',       "Prerelease server version") do |id|
          config.adapter = EmmyHttp::Server::Server
        end
        #opts.on('-l', '--log FILE',    "Log to file")   { |file| config.log    = file }
        #opts.on('-o', '--output FILE', "Logs stdout to file") { |file| config.stdout = config.stderr = file }
        #opts.on('-P', '--pid FILE',    "Pid file")      { |file| config.pid    = file }

        # actions
        opts.separator "Actions:"
        opts.on("-i", "--info",      "Shows server configuration")  { @action = :show_configuration }
        opts.on("-c", "--console",   "Start a console")             { @action = :start_console }
        opts.on('-t', '--stop',      "Terminate background server") { @action = :stop_server }
        opts.on("-h", "--help",      "Display this help message")   { @action = :display_help }
        opts.on("-v", "--version",   "Display Emmy version.")       { @action = :display_version }
      end
    end

    def defaults!
      if config.environment == "development"
        config.stdout = "#{config.backend}.stdout"
        config.stderr = config.stdout
      end

      config.pid = "#{config.backend}.pid"
      config.log = "#{config.backend}.log"

      config.adapter ||= EmmyExtends::Thin::Controller rescue nil
    end

    def instance_defaults!(id)
      if config.id
        config.url.port += id if config.servers
        config.pid  = "#{config.backend}#{id}.pid"
        config.log  = "#{config.backend}#{id}.log"
      end
    end

    def run_action
      # Bootstrap
      bootstrap!
      # start action
      send(action)
      self
    end

    def daemonize_server
      each_server do
        Process.fork do
          Process.setsid
          exit if fork

          Fibre.reset
          # Boot instance
          instance!

          scope_pid(Process.pid) do |pid|
            puts pid
            File.umask(0000)
            bind_standard_streams
            start_server
          end
        end
      end
      sleep(1)
    end

    def start_server
      Emmy.run do
        trap("INT")  { Emmy.stop }
        trap("TERM") { Emmy.stop }

        Emmy.fiber_block do
          file = backend_file
          Backend.module_eval(File.read(file), file)
        end
      end
    end

    def stop_server
      each_server do
        instance!
        stop_pid(config.pid)
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
      on :bootstrap, &b
    end

    def each(&b)
      on :instance, &b
    end

    def bootstrap!
      bootstrap.fire_for(self)
    end

    def instance!
      instance.fire_for(self, config.id)
    end

    private

    def each_server
      unless config.servers
        yield
        return
      end

      config.servers.times do |id|
        config.id = id
        yield
      end
    end

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
      stop_pid(config.pid)
      File.open(config.pid, 'w') { |f| f.write(pid) }
      if block_given?
        yield pid
        delete_pid
      end
    end

    def stop_pid(pid_file)
      return unless File.exists?(pid_file)

      pid = File.read(pid_file).to_i
      unless pid.zero?
        Process.kill("TERM", pid)
        puts "Stopping..."
        while File.exists?(config.pid)
          sleep(0.1)
        end
        #Process.wait(pid)
      end
    rescue Errno::ESRCH
    end

    def delete_pid
      File.delete(config.pid)
    end

    def bind_standard_streams
      STDIN.reopen("/dev/null")
      STDOUT.reopen(config.stdout, "a") if config.stdout

      if config.stdout == config.stderr
        STDERR.reopen(STDOUT)
      else
        STDERR.reopen(config.stderr, "a") if config.stderr
      end
    end

    #<<<
  end
end
