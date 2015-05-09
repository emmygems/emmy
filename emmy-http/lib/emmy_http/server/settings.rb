module EmmyHttp
  class Settings
    include ModelPack::Document

    # options
    attribute :address, default: '0.0.0.0'
    attribute :port,    default: 3003
    attribute :socket

    # system
    attribute :user
    attribute :pid
    attribute :log

    # flags
    attribute :daemonize, default: false
    attribute :logging,   default: true

    # SSL support
    attribute :ssl
    attribute :ssl_key
    attribute :ssl_cert


  end
end
