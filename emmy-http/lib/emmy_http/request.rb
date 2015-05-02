module EmmyHttp
  class Request
    include ModelPack::Document
    using EventObject

    #def_delegator :operation, :sync, :init, :head, :success, :error, :init!, :head!, :success!, :error!, :to_a

    attribute :type, default: "GET" # word *method* reserved in ruby objects
    attribute :url,
        writer: ->(v) { v.is_a?(String) ? Addressable::Template.new(v) : v },
        serialize: ->(v) { v.is_a?(Addressable::Template) ? v.pattern : v.to_s }
    dictionary :headers

    attribute  :path, # replace url.path
        writer: ->(v) { v.is_a?(String) ? Addressable::Template.new(v) : v },
        serialize: ->(v) { v.is_a?(Addressable::Template) ? v.pattern : (v ? v.to_s : v) }

    attribute  :query    # replace url.query
    attribute  :user     # replace url.user
    attribute  :password # replace url.password
    dictionary :params   # params for url template

    # POST, PUT
    attribute :body    # string, json hash
    attribute :form    # hash form
    attribute :json    # serializable hash/object to json
    attribute :file    # path

    attribute :keep_alive, predicate: true                 # keep connection alive
    attribute :encoding, default: true, predicate: true    # encode request
    attribute :decoding, default: true, predicate: true    # decode response
    attribute :redirects, default: 6                       # max redirects to follow
    attribute :raise_error, predicate: true, default: true # raise error or return nil

    object :timeouts, class_name: Timeouts, default: Timeouts
    object :ssl, class_name: SSL
    object :proxy, class_name: Proxy

    attribute :adapter,
        writer:    ->(class_name) { class_name.is_a?(String) ? constantize(class_name) : class_name },
        serialize: ->(value) { value.to_s }

    def operation
      @operation ||= new_operation
    end

    def new_operation
      EmmyHttp::Operation.new(self, adapter.new)
    end

    alias op operation

    def sync
      operation.sync
    end

    def real_url
      if url.is_a?(Addressable::Template)
        url.expand(params)
      else
        Addressable::URI.parse(url.to_s)
      end
    end

    def real_path
      return nil unless path
      if path.is_a?(Addressable::Template)
        path.expand(params)
      else
        Addressable::URI.parse(path.to_s)
      end
    end

    EmmyHttp::HTTP_METHODS.each do |name|
      self.def name do |a={}|
        update_attributes(a.is_a?(String) ? {url: a} : a)
        self
      end
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
