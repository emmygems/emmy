module EmmyHttp
  module Utils
    extend self

    # CONTENT_TYPE becomes Content-Type
    def convert_headers(headers)
      headers.inject({}) { |h, (k, v)|
        h[k.split(/[_-]/).map { |w| w.downcase.capitalize }.join('-')] = v; h
      }
    end

  end
end
