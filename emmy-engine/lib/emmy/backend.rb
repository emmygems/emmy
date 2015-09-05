module Emmy
  module Backend
    extend EmmyMachine::ClassMethods
    using Emmy

    module_function

    def app(name=nil, &b)
      name ||= Emmy::Runner.instance.config.backend

      if b
        app = EmmyHttp::Application.new
        app.instance_eval(&b)
        apps(name, app)
      else
        apps(name)
      end
    end

    def apps(name, app=nil)
      @apps ||= {}
      app ? @apps[name || :default] = app : @apps[name || :default]
    end

    def to_a
      apps.to_a
    end

    #<<<
  end
end
