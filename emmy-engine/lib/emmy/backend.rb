module Emmy
  module Backend
    extend EmmyMachine::ClassMethods
    using Emmy

    module_function

    attr_reader :apps

    def app(name: nil, &b)
      @apps ||= {}
      name ||= Emmy::Runner.instance.config.backend

      if b
        app = EmmyHttp::Application.new
        app.instance_eval(&b)
        @apps[name] = app
      else
        @apps[name]
      end
    end

    #<<<
  end
end
