require "spec_helper"

describe EmmyMachine do
  using EventObject

  it "test run_block" do
    expect { |block|
      EmmyMachine.run_block &block
    }.to yield_control
  end

  it "test run_block with raise" do
    expect {
      EmmyMachine.run_block do
        raise "error"
      end
    }.to raise_error FiberError
  end

  it "test connect" do
    expect { |block|
      EventMachine.run do
        http = EmmyMachine.connect("tcp://github.com:80")
        http.on :connect do
          http.send_data "GET / HTTP/1.1\r\n" \
            "Host: ru.wikipedia.org\r\n" \
            "User-Agent: Ruby\r\n" \
            "Accept: text/html\r\n" \
            "Connection: close\r\n\r\n"
        end

        http.on :data, &block
        http.on :close do
          EventMachine.stop
        end
      end
    }.to yield_control.at_least(1)
  end

  context "Reactor required" do
    around do |example|
      EventMachine.run do
        example.run
        EventMachine.stop
      end
    end

    it "test running?" do
      expect(EmmyMachine.running?).to be true
    end
  end
end
