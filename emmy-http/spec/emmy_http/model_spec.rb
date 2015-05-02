require "spec_helper"
require "fakes"
using Fibre::Synchrony

describe EmmyHttp::Model do

  before do
    stub_const("EmmyMachine", FakeEventMachine)
  end

  class HTTPBin
    include EmmyHttp::Model
    adapter FakeAdapter
    url "http://httpbin.org"
    header "Content-Type" => "application/json"

    get '/get',   as: :get_request
    post '/post', as: :post_request
  end

  class HTTPSBin < HTTPBin
    url "https://httpbin.org"

    get '/get',   as: :get_request
  end

  around do |example|
    EmmyMachine.run_block &example
  end

  it "has requests from model" do
    res = {
      get_response: HTTPBin.get_request!,
      post_response: HTTPBin.post_request!(form: {a: 5, b: 6})
    }.sync

    expect(res[:get_response].status).to be(200)
    expect(res[:post_response].status).to be(200)
  end

  it "inherits models" do
    http_req = HTTPBin.get_request
    https_req = HTTPSBin.get_request
    https_req.sync
    expect(http_req.real_url.to_s).to eq('http://httpbin.org')
    expect(https_req.real_url.to_s).to eq('https://httpbin.org')
  end
end
