module EmmyHttp
  class Response
    using EventObject
    include ModelPack::Document

    attribute  :status,  default: 0
    dictionary :headers, writer: -> (head) { EmmyHttp::Utils.convert_headers(head) }
    attribute  :body,    default: ''
    attribute  :finished, predicate: true#, hidden: true

    events :data, :done

    def initialize
      on :data do |chunk|
        body << chunk
      end
    end

    def clear
      @status  = 0
      @headers = {}
      @body    = ''
    end

    def finish
      @finished = true
      done!
    end

    def chunked_encoding?
      headers['Transfer-Encoding'] =~ /chunked/i
    end

    def keepalive?
      headers['Keep-Alive'] =~ /keep-alive/i
    end

    def compressed?
      headers['Content-Encoding'] =~ /gzip|compressed|deflate/i
    end

    def content_length?
      headers['Content-Length'] =~ /\A\d+\z/
    end

    def content_length
      content_length? ? headers['Content-Length'].to_i : nil
    end

    def content_type
      headers['Content-Type'] =~ /\A([^;]*)/; $1
    end

    def location
      headers['Location']
    end

    def content
      @content ||= case content_type
        when 'application/json'
          begin
            JSON.parse(body)
          rescue JSON::ParserError => e
            raise ParserError, e.to_s
          end
      else
        nil
      end
    end

    def redirection?
      300 <= status && 400 > status
    end

    def to_a
      [status, headers, body]
    end

    #<<<
  end
end
