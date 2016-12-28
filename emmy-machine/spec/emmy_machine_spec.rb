require "spec_helper"

describe EmmyMachine do
  using EventObject

  it "calls run_once" do
    expect { |block|
      EmmyMachine.run_once &block
    }.to yield_control
  end

  it "calls run_once then an error will be raised" do
    expect {
      EmmyMachine.run_once do
        raise "error"
      end
    }.to raise_error Fibre::FiberError
  end

  it "connects to the Github's index page" do
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

  context "The reactor is required" do
    around do |example|
      EmmyMachine.run do
        example.run
        EmmyMachine.stop
      end
    end

    it "Async/await scenario" do
      EmmyMachine.async do
        res = EmmyMachine.await do |f|
          EventMachine.next_tick do
            f.resume 42
          end
        end
        expect(res).to be(42)
      end
    end

    it "is runned" do
      expect(EmmyMachine.running?).to be true
    end
  end

  context "The reactor and the fibers are required" do
    around do |example|
      EventMachine.run do
        Fibre.pool.checkout do
          example.run
          EventMachine.stop
        end
      end
    end

    it "is deferred" do
      defer = EmmyMachine::Deferred.new
      EmmyMachine.timer(0) do
        defer.success!('OK')
      end
      res = defer.await

      expect(res).to eq('OK')
    end
  end

end
