module EmmyHttp
  class SSL
    include ModelPack::Document

    attribute :private_key_file
    attribute :cert_chain_file
    attribute :ssl_version, default: :TLSv1
    attribute :verify_peer, predicate: true
  end
end
