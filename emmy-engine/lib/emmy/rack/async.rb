module Emmy
  module Rack
    class Async
      def initialize(app, options={})
        @app = app
        @rescue_exception = options[:rescue_exception] || (->(env, ex) { [500, {}, ["Internal Server Error"]] })
      end

      def call(env)
        call_app = lambda do
          result = @app.call(env)
          env['async.callback'].call result
        end

        Emmy.async(&call_app)
        throw :async
      rescue => ex
        @rescue_exception[env, ex]
      end
    end
  end
end
