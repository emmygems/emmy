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
        instance.request.copy.tap { |req| req.update_attributes(a) if a }
      end

      def request!(a=nil)
        request(a).operation
      end

      def adapter(name)
        instance.request.adapter = name
      end

      def url(uri)
        instance.request.url = uri
      end

      def defaults(attributes)
        instance.request.update_attributes(attributes)
      end

      def headers(head)
        instance.request.headers.merge!(head)
      end

      def raise_error(flag)
        instance.request.raise_error = flag
      end

      alias header headers

      EmmyHttp::HTTP_METHODS.each do |name|
        define_method name do |path, as: nil|
          cdef as.to_s do |*a|
            instance.var(as.to_s, request(path: path))
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
