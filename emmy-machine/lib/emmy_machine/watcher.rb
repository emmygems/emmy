module EmmyMachine
  module Watcher
    using EventObject

    def self.included(base)
      base.events :read, :write
      base.class_eval do
        alias_method :notify_readable, :read!
        alias_method :notify_writable, :write!
      end
    end

    #<<<
  end
end
