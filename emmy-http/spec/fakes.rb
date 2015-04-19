Connection = EmmyMachine::Connection

module FakeEventMachine
  extend EmmyMachine::ClassMethods

  def connect(adapter, init)
    conn = Class.new
    conn.extend Connection
    init.call
    adapter.connected(conn)
    conn
  end

  extend self
end

class FakeAdapter
  attr_accessor :delegate
  include EmmyHttp::Adapter

  def initialize_connection
    self.delegate.init! delegate
  end

  def connected(conn)
    # replace request with timer
    EventMachine.add_timer(0) do
      response = EmmyHttp::Response.new
      response.headers = {'Content-Type' => 'text/html'}
      response.status  = 200
      self.delegate.head!(response, delegate, conn)
      response.body = "OK"
      self.delegate.success!(delegate.response, delegate, conn)
    end
  end

  def to_a
    [self, method(:initialize_connection)]
  end
end
