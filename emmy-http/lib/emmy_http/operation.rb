module EmmyHttp
  class Operation
    using EventObject

    attr_reader :request
    attr_reader :response
    attr_reader :adapter
    attr_reader :connection

    events :init, :head, :success, :error

    def initialize(request, adapter)
      raise "invalid adapter" if adapter.nil? || !adapter.respond_to?(:to_a) || !adapter.respond_to?(:delegate=)
      @request          = request
      @adapter          = adapter
      @adapter.delegate = self
    end

    def connect
      @connection ||= EmmyMachine.connect(*self)
    end

    def reconnect
      EmmyMachine.reconnect(*self)
    end

    def sync
      Fiber.sync do |fiber|
        # create connection
        connect

        on :init do |connection|
          # update connection
          @connection = connection
        end

        on :head do |response, operation, conn|
          # set response
          @response = response
        end

        on :success do |response, operation, conn|
          # return response
          fiber.resume response
        end

        on :error do |error, operation, conn|
          # return error as exception
          if request.raise_error?
            fiber.leave ConnectionError, error.to_s
          else
            fiber.resume nil
          end
        end
      end
    end

    def to_a
      adapter.to_a
    end

    def serializable_hash
      {
        request:  request.serializable_hash,
        response: response && response.serializable_hash
      }
    end

    private
=begin
    def setup
      adapter.setup

      on :init do |connection|
        @connection = connection
      end

      on :head do |operation, conn|
        @response = request.response_class.new
        response.headers = operation.adapter.headers
      end

      on :success do |response, operation, conn|
        response.status = operation.adapter.status
        response.body   = operation.adapter.body
      end

      on :error do |error, operation, conn|
        response.status = operation.adapter.status
      end
    end
=end
    #<<<
  end
end
