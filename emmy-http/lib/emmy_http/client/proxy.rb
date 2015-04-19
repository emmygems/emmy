module EmmyHttp
  class Proxy
    include ModelPack::Document

    attribute :type
    attribute :host
    attribute :port
    attribute :username
    attribute :password
  end
end
