require "spec_helper"

describe Emmy do
  it "do request to google.com" do
    response = EmmyHttp.request.get('http://google.com').sync
    p response
    expect(response.status).to be(200)
    expect(response.body.size).to be > 100
  end
end
