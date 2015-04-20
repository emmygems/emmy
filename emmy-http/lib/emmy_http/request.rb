module EmmyHttp
  class Request
    include ModelPack::Document
    using EventObject

    #def_delegator :operation, :sync, :init, :head, :success, :error, :init!, :head!, :success!, :error!, :to_a

    attribute :type, default: "GET" # word *method* reserved in ruby
    attribute :url,
        writer: ->(url) { url.is_a?(URI) ? url : URI.parse(url) },
        serialize: ->(value) { value.to_s }
    dictionary :headers

    attribute :path    # replace url.path
    attribute :query   # replace url.query

    # POST, PUT
    attribute :body    # string, json hash
    attribute :form    # hash form
    attribute :json    # serializable hash/object to json
    attribute :file    # path

    attribute :keep_alive, predicate: true
    attribute :redirects, default: 6
    attribute :raise_error, predicate: true, default: true

    object :timeouts, class_name: Timeouts, default: Timeouts
    object :ssl, class_name: SSL
    object :proxy, class_name: Proxy

    attribute :adapter,
        writer:    ->(class_name) { class_name.is_a?(String) ? constantize(class_name) : class_name },
        serialize: ->(value) { value.to_s }

    def operation
      @operation ||= EmmyHttp::Operation.new(self, adapter.new)
    end

    alias op operation

    def sync
      operation.sync
    end

    EmmyHttp::HTTP_METHODS.each do |name|
      self.def name do |a={}|
        update_attributes(a.is_a?(String) ? {url: a} : a)
        self
      end
    end

    def ssl?
      ssl || url.scheme == 'https' || url.port == 443
    end

    private

    def error(message)
      raise RequestError, message
    end

    def constantize(class_name)
      return nil unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ class_name
      Object.module_eval("::#{$1}", __FILE__, __LINE__)
    end

    #<<<
  end
end
