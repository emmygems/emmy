#
# class Google
#   include  EmmyHttp::Model
#   adapter  EmmyExtends::EmHttpRequest
#   defaults {
#     headers: {
#       'Content-Type' => 'application/json'
#     }
#   }
#
#   post ''
# end
#
# google = Google.new(url: 'http://google.com')
# response = google.sync

#
# module DigitalOcean
#   using EventObject
#   API_TOKEN = "b7d03a6947b217efb6f3ec3bd3504582"
#
#   class DigitalOcean::Error < StandardError; end
#
#   class Request
#     include EmmyHttp::Model
#     adapter EmmyHttp::Client::Adapter
#     header 'Content-Type' => 'application/json'
#     header "Authorization: Bearer #{API_TOKEN}"
#
#     events :success, :error
#
#     def sync
#       connect
#
#       Fiber.sync do |f|
#         on :success do |content|
#           f.resume content
#         end
#
#         on :error do |message|
#           raise DigitalOcean::Error, message
#         end
#       end
#     end
#
#     def request
#       op = super(
#
#       ).op
#
#       op.on :success do |response, operation, conn|
#         success!(response.content)
#       end
#
#       op.on :error do |message, operation, conn|
#         error!(message)
#       end
#     end
#   end
#
#
#   class Droplets < Request
#     get  list: '/v2/droplets'
#     post new:  '/v2/droplets'
#     get  get:  '/v2/:id'
#
#
#   end
# end
require 'singleton'

module EmmyHttp
  module Model
    using EventObject

    def self.included(base)
      base.extend ClassMethods
      base.include Singleton
      base.include InstanceMethods
    end

    module InstanceMethods
      def request
        @request ||= EmmyHttp::Request.new
      end
    end

    module ClassMethods
      def request(a=nil)
        instance.request.tap { |req| req.update_attributes(a) if a }
      end

      def adapter(name)
        request.adapter = name
      end

      def url(uri)
        request.url = uri
      end

      def defaults(attributes)
        request.update_attributes(attributes)
      end

      def headers(head)
        request.headers.merge!(head)
      end

      def raise_error(flag)
        request.raise_error = flag
      end

      alias header headers

      EmmyHttp::HTTP_METHODS.each do |name|
        define_method name do |path, as: nil|
          cdef as.to_s do |*a|
            instance.var(as.to_s, request.copy.tap { |r| r.update_attributes(path: path) })
          end

          cdef "#{as}!" do |*a, &b|
            send(as, *a, &b)
          end
        end
      end
    end

    #<<<
  end
end
