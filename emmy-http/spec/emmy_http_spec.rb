require "spec_helper"
require "fakes"
using EventObject
using Fibre::Synchrony

describe EmmyHttp do
  include EmmyHttp

  before do
    stub_const("EmmyMachine", FakeEventMachine)
  end

  around do |example|
    EmmyMachine.run_once &example
  end

  it "should send HTTP-request with the fake adapter" do
    request = EmmyHttp::Request.new(
      type: 'get',
      url: 'http://httpbin.org'
    )
    operation = EmmyHttp::Operation.new(request, FakeAdapter.new)
    response = operation.await

    expect(response.status).to be 200
    expect(response.headers).to include("Content-Type")
    expect(response.body).to eq "OK"
  end

  it "should send HTTP-request using the short syntax" do
    response = request(adapter: FakeAdapter, raise_error: false).get('http://google.com').await

    expect(response).to_not be nil
    expect(response.status).to be 200
    expect(response.headers).to include("Content-Type")
    expect(response.body).to eq "OK"
  end

  it "should send several requests in parallel" do
    req = request(adapter: FakeAdapter, raise_error: false)
    responses = {
      a: [req.copy.get('http://httpbin.org'), req.copy.get('http://httpbin.org')],
      b: req.copy.get('http://httpbin.org')
    }.await!

    expect(responses[:a][0].status).to be 200
    expect(responses[:a][1].status).to be 200
    expect(responses[:b].status).to be 200
  end

  it "should be waiting couple seconds" do
    timeout = EmmyHttp::Timer.new(2)
    res = timeout.await

    expect(res).to be true
  end

  it "should pack settings of the request in the Hash/Array structure" do
    request = EmmyHttp::Request.new(
      type: 'get',
      url: 'http://httpbin.org'
    )
    request_hash = request.serializable_hash

    expect(request_hash).to include(type: 'get', url: 'http://httpbin.org')
  end
end
