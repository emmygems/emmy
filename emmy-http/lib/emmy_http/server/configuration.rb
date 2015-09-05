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
    attribute :timeout,     default: 0

    object :ssl,      class_name: SSL

    # cluster options
    attribute :id
    attribute :servers

    attribute :adapter,
        writer:    ->(class_name) { class_name.is_a?(String) ? UtilPack.constantize(class_name) : class_name },
        serialize: ->(value) { value.to_s }
  end
end
