module EmmyHttp
  class Timer
    using EventObject
    attr_accessor :interval

    events :timeout

    def initialize(interval)
      @interval = interval
    end

    def start
      EmmyMachine.timeout(interval) do
        timeout!
      end
    end

    def await
      Fiber.await do |fiber|
        # create connection
        start

        on :timeout do
          fiber.resume true
        end
      end
    end

    #<<<
  end
end
