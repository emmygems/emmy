module EmmyMachine
  module ClassMethods
    def run(&b)
      EventMachine.reactor_running? ? b.call : EventMachine.run(&b)
    end

    def loop
      EventMachine.run
    end

    def running?
      EventMachine.reactor_running?
    end

    def stop
      EventMachine.stop
    end

    def run_block &b
      EventMachine.run do
        fiber_block do
          yield
          stop
        end
      end
    end

    def fiber_block &b
      Fibre.pool.checkout &b
    end

    # Periodic timer
    def timer(interval=1, &b)
      EventMachine::PeriodicTimer.new(interval) do
        fiber_block &b
      end
    end

    # One run timer
    def timeout(interval=1, &b)
      EventMachine::Timer.new(interval) do
        fiber_block &b
      end
    end

    # Connect to remote server
    #
    # EmmyMachine.connect("tcp://localhost:5555", handler, *args)
    # EmmyMachine.connect("ipc://mypoint")
    def connect(url, *a, &b)
      url = URI(url.to_s)
      handler = a.empty? ? Connection : a.shift
      b ||= a.shift if a.first.is_a?(Proc) || a.first.is_a?(Method)

      case url.scheme
      when "tcp" then
        EventMachine.connect(url.host, url.port, handler, *a, &b)
      when "ipc" then
        EventMachine.connect_unix_domain(url[6..-1], handler, *a, &b)
      else
        raise ArgumentError, "unsupported url scheme"
      end
    end

    # Bind server
    #
    # EmmyMachine.bind("tcp://localhost:5555", ServerConnection)
    # EmmyMachine.bind("ipc://mypoint", ServerConnection)
    def bind(url, *a, &b)
      url = URI(url.to_s)
      handler = a.empty? ? Connection : a.shift
      b ||= a.shift if a.first.is_a?(Proc) || a.first.is_a?(Method)

      case url.scheme
      when "tcp" then
        EventMachine.start_server(url.host, url.port, handler, *a, &b)
      when "ipc" then
        EventMachine.start_unix_domain_server(url[6..-1], handler, *a, &b)
      else
        raise ArgumentError, "unsupported url scheme"
      end
    end

    # Watch socket
    #
    # EmmyMachine.watch(socket, ClientConnection)  - notify read by default
    # EmmyMachine.watch(socket, ClientConnection, notify_readable: false, notify_writable: true) - notify write only
    def watch(socket, handler, *a, notify_readable: true, notify_writable: false, &b)
      b ||= a.shift if a.first.is_a?(Proc) || a.first.is_a?(Method)
      EventMachine.attach_io(socket, true, handler, *a, &b).tap do |conn|
        conn.notify_readable = true if notify_readable
        conn.notify_writable = true if notify_writable
      end
    end

    def reconnect(url, connection, *a, &b)
      url = URI(url.to_s)
      EventMachine.reconnect(url.host, url.port, connection, &b)
    end

    def next_tick
      fiber = Fiber.current
      EventMachine.next_tick { fiber.resume }
      Fiber.yield
    end

    def sleep(time)
      fiber = Fiber.current
      timeout(time) { fiber.resume }
      Fiber.yield
    end
  end
end
