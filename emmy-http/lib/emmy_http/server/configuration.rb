module EmmyHttp
  class Configuration
    include ModelPack::Document

    # options
    attribute :environment
    attribute :backend,     default: 'backend'
    attribute :url,
        default: -> { Addressable::URI.parse('tcp://0.0.0.0:3003') },
        writer:    ->(v) { v.is_a?(String) ? Addressable::URI.parse(v) : v },
        serialize: ->(v) { v.to_s }

    # system
    attribute :user
    attribute :group
    attribute :pid
    attribute :log
    attribute :stdout,      default: '/dev/null'
    attribute :stderr,      default: '/dev/null'

    object :ssl,            class_name: SSL

    # cluster options
    attribute :id,            default: 0
    attribute :servers,       default: 1
  end
end
