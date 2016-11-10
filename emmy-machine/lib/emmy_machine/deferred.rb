module EmmyMachine
  class Deferred
    using EventObject
    events :success, :error

    def await
      Fiber.await do |fiber|
        on :success do |response|
          fiber.resume response
        end

        on :error do |error|
          fiber.leave error
        end
      end
    end

    #<<<
  end
end
