require "spec_helper"
using Emmy

describe "emmy-engine" do
  around do |example|
    Emmy.run_once &example
  end

  it "sends a request to httpbin.org #1" do
    response = Emmy::Http.request.get('http://httpbin.org').await

    expect(response.status).to be(200)
    expect(response.content_type).to eq('text/html')
    expect(response.body.size).to be > 100
  end

  it "sends a request to httpbin.org #2" do
    response = Emmy::Http.request(url: 'http://httpbin.org').await

    expect(response.status).to be(200)
    expect(response.content_type).to eq('text/html')
    expect(response.body.size).to be > 100
  end

  it "sends the bundle of requests in parallel" do
    res = [Emmy::Http.request!(url: 'http://httpbin.org'), Emmy::Http.request!(url: 'http://httpbin.org')].await
    expect(res[0].status).to be(200)
    expect(res[1].status).to be(200)
  end
end
