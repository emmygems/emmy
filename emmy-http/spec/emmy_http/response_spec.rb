require "spec_helper"
using EventObject

describe EmmyHttp::Response do
  it "concatinates chunks in body string" do
    subject.data!('hello')
    subject.data!('world')

    expect(subject.body).to eq('helloworld')
  end
end
