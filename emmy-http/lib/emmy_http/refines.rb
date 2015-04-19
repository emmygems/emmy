module EmmyHttp
  refine Kernel do
    def request(*a, &b)
      EmmyHttp.request(*a, &b)
    end

    def request!(*a, &b)
      EmmyHttp.request!(*a, &b)
    end
  end
end
