#!/usr/bin/env ruby
#
# = SocketServerのテスト用クラス
# Author:: arosh
#
# 実際にはサーバー側をRuby、クライアント側をAdobe Flexで行う予定だが、
# テスト用に用意した。
# チャット機能を本当に実装するかどうかは不明。
#
require "socket"

Thread.abort_on_exception = true

class SocketClient
  def initialize(name, port = 7650, host = "localhost")
    @name = name
    @port = port
    @host = host
  end

  def start
    TCPSocket.open(@host, @port) {|sock|
      @sock = sock

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
      p @sock.gets
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

