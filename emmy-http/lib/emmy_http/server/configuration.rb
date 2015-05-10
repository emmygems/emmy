module EmmyHttp
  class Configuration
    include ModelPack::Document

    # options
    attribute :environment
    attribute :backend,     default: 'backend'
    attribute :address,     default: '0.0.0.0'
    attribute :port,        default: 3003
    attribute :socket

    # emmy
    attribute :backend

    # system
    attribute :user
    attribute :group
    attribute :pid
    attribute :log

    # flags
    attribute :daemonize, default: false
    attribute :logging,   default: true

    object :ssl, class_name: SSL

  end
end
