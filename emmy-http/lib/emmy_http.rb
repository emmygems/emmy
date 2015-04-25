require "addressable/uri"
require 'addressable/template'
require "model_pack"
require "emmy_http/version"
require "forwardable"

module EmmyHttp
  class HttpError < StandardError; end
  class ParserError < HttpError; end
  class RequestError < HttpError; end
  class ConnectionError < HttpError; end
  class TimeoutError < HttpError; end
  class EncoderError < HttpError; end
  class DecoderError < HttpError; end

  HTTP_METHODS = %w(get head delete put post patch options)

  autoload :Adapter,   "emmy_http/adapter"
  autoload :Timeouts,  "emmy_http/client/timeouts"
  autoload :Proxy,     "emmy_http/client/proxy"
  autoload :SSL,       "emmy_http/client/ssl"
  autoload :Request,   "emmy_http/request"
  autoload :Operation, "emmy_http/operation"
  autoload :Response,  "emmy_http/response"
  autoload :Timeout,   "emmy_http/timeout"
  autoload :Utils,     "emmy_http/utils"
  autoload :Model,     "emmy_http/model"

  extend self

  def request(*a)
    EmmyHttp::Request.new(*a).tap { |req| yield(req) if block_given? }
  end

  def request!(*a)
    request(*a, &b).operation
  end
end
