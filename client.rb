#!/usr/bin/env ruby
require "socket"

Thread.abort_on_exception

class SocketClient
  def initialize(name, port = 4444, host = "localhost")
    @name = name
    @port = port
    @host = host
  end

  def open
    TCPSocket.open(@host, @port) {|sock|
      @sock = sock
      yield
    }
  end

  def start
    open {|sock|
      send(@name)

      Thread.start do
        recieve
      end

      get_message
    }
  end

  def send(str)
    @sock.puts str
  end

  def recieve
    while true
      puts @sock.gets.chomp
    end
  end

  def get_message
    while str = gets
      send(str.chomp)
    end
  end
end

print "Your Name : "
name = gets
s = SocketClient.new(name.chomp)
s.start

