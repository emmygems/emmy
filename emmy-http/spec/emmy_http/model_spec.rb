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

  around do |example|
    EmmyMachine.run_block &example
  end

  it "have requests from model" do
    res = {
      get_response: HTTPBin.get_request!,
      post_response: HTTPBin.post_request!(form: {a: 5, b: 6})
    }.sync

    expect(res[:get_response].status).to be(200)
    expect(res[:post_response].status).to be(200)
  end
end
