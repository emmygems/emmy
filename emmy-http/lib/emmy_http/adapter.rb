module EmmyHttp
  module Adapter
    %w(delegate= to_a).each do |method|
      define_method method do
        raise 'method not implemented'
      end
    end

    #<<<
  end
end
