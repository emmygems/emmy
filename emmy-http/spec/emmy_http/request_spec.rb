require "spec_helper"
using EventObject

describe EmmyHttp::Request do
  it "ssl flag" do
    req1 = EmmyHttp::Request.new(url: 'http://httpbin.org')
    req2 = EmmyHttp::Request.new(url: 'https://httpbin.org')
    req3 = EmmyHttp::Request.new(url: 'http://httpbin.org:443')

    expect(req1.ssl?).to eq false
    expect(req2.ssl?).to eq true
    expect(req3.ssl?).to eq true
  end
end
