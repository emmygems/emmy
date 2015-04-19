module EmmyMachine
  module Connection
    using EventObject

    def self.included(base)
      base.events :init, :connect, :data, :close, :error, :handshake, :verify_peer
      base.class_eval do
        alias_method :post_init, :init!
        alias_method :connection_completed, :connect!
        alias_method :receive_data, :data!
        alias_method :ssl_handshake_completed, :handshake!
        alias_method :ssl_verify_peer, :verify_peer!
      end
    end

    def unbind(reason=nil)
      close!(reason)
      error!(reason) if error?
    end
  end
end
