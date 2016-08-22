require "spec_helper"
using Emmy

describe "emmy-engine" do
  around do |example|
    Emmy.run_block &example
  end

  it "sends a request to google.com #1" do
    response = Emmy::Http.request.get('http://google.com').sync

    expect(response.status).to be(200)
    expect(response.content_type).to eq('text/html')
    expect(response.body.size).to be > 100
  end

  it "sends a request to google.com #2" do
    response = Emmy::Http.request(url: 'http://google.com').sync

    expect(response.status).to be(200)
    expect(response.content_type).to eq('text/html')
    expect(response.body.size).to be > 100
  end

  it "sends the bundle of requests in parallel" do
    res = [Emmy::Http.request!(url: 'http://google.com'), Emmy::Http.request!(url: 'http://google.com')].sync
    expect(res[0].status).to be(200)
    expect(res[1].status).to be(200)
  end
end
