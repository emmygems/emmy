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
    EmmyMachine.run_block &example
  end

  it "do http request with fake adapter" do
    request = EmmyHttp::Request.new(
      type: 'get',
      url: 'http://google.com'
    )
    operation = EmmyHttp::Operation.new(request, FakeAdapter.new)
    response = operation.sync

    expect(response.status).to be 200
    expect(response.headers).to include("Content-Type")
    expect(response.body).to eq "OK"
  end

  it "do http request with short syntax" do
    response = request(adapter: FakeAdapter, raise_error: false).get('http://google.com').sync

    expect(response).to_not be nil
    expect(response.status).to be 200
    expect(response.headers).to include("Content-Type")
    expect(response.body).to eq "OK"
  end

  it "do async requests" do
    req = request(adapter: FakeAdapter, raise_error: false)
    responses = {
      a: [req.copy.get('http://google.com').op, req.copy.get('http://google.com').op],
      b: req.copy.get('http://google.com')
    }.sync!

    expect(responses[:a][0].status).to be 200
    expect(responses[:a][1].status).to be 200
    expect(responses[:b].status).to be 200
  end

  it "should wait a couple seconds" do
    timeout = EmmyHttp::Timeout.new(2)
    res = timeout.sync

    expect(res).to be true
  end

  it "should serialize request" do
    request = EmmyHttp::Request.new(
      type: 'get',
      url: 'http://google.com'
    )
    request_hash = request.serializable_hash

    expect(request_hash).to include(type: 'get', url: 'http://google.com')
  end
end
