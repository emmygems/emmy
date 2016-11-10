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
        @request ||= self.class.superclass.respond_to?(:instance) ?
                     self.class.superclass.instance.request.copy :
                     EmmyHttp::Request.new
      end

      def api
        @api ||= {}
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

      def api
        instance.api
      end

      alias header headers

      EmmyHttp::HTTP_METHODS.each do |name|
        define_method name do |path, as: nil|
          instance.api[as] = {path: path}
          if as
            define_singleton_method as.to_s do |a=nil|
              request(path: path).tap { |r| r.update_attributes(a) if a }
            end

            define_singleton_method "#{as}!" do |*a, &b|
              send(as, *a, &b).operation
            end
          end
        end
      end
    end

    #<<<
  end
end
