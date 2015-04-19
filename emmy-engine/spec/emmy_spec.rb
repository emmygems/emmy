require "spec_helper"

describe Emmy do
  around do |example|
    Emmy.run_block &example
  end

  it "do request to google.com #1" do
    response = Emmy::Http.request.get('http://google.com').sync

    expect(response.status).to be(200)
    expect(response.content_type).to eq('text/html')
    expect(response.body.size).to be > 100
  end

  it "do request to google.com #2" do
    response = Emmy::Http.request(url: 'http://google.com').sync

    expect(response.status).to be(200)
    expect(response.content_type).to eq('text/html')
    expect(response.body.size).to be > 100
  end
end
