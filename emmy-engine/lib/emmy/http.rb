module Emmy
  class Http
    include EmmyHttp::Model
    adapter EmmyHttp::Client::Adapter
  end
end
