require "spec_helper"

describe "emmy/runner" do
  it "run server" do
    runner = Emmy::Runner.instance
    expect(runner).to receive(:start_server)
    runner.run_action
  end

  it "display the help message" do
    runner = Emmy::Runner.instance
    runner.argv = ["-h"]
    runner.run_action
  end

  it "shows server configuration" do
    runner = Emmy::Runner.instance
    runner.argv = ["-i"]
    runner.run_action
  end

  it "changes server environment" do
    runner = Emmy::Runner.instance
    runner.argv = ["-i", "-e", "test"]
    runner.run_action

    expect(ENV['RACK_ENV']).to eq('test')
    expect(Emmy::Runner.instance.config.environment).to eq('test')
  end

  it "start a console" do
    require 'irb'
    expect(IRB).to receive(:start)
    runner = Emmy::Runner.instance
    runner.argv = ["-c"]
    runner.run_action
  end

  context "catch stdout" do
    before do
      $stdout = StringIO.new
    end

    def out_string
      $stdout.rewind
      $stdout.read
    end

    after(:all) do
      $stdout = STDOUT
    end

    it "Display Emmy version" do
      runner = Emmy::Runner.instance
      runner.argv = ["-v"]
      runner.run_action

      expect(out_string).to eq(Emmy::VERSION+"\n")
    end
  end
end
