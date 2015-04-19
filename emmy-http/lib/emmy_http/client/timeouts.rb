module EmmyHttp
  class Timeouts
    include ModelPack::Document

    attribute :connect, default: 10
    attribute :inactivity, default: 30
  end
end
