module EmmyHttp
  class Backend
    SUPPORTED_COMMANDS = %w(start stop restart)

    def supported_commands
      const_get(:SUPPORTED_COMMANDS)
    end

    SUPPORTED_COMMANDS.each do |method|
      define_method method do
        raise 'method not implemented'
      end
    end

    #<<<
  end
end
