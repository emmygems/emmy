require "spec_helper"
using EventObject

describe EmmyHttp::Response do
  it "should response filled with chunks" do
    subject.data!('hello')
    subject.data!('world')

    expect(subject.body).to eq('helloworld')
  end
end
