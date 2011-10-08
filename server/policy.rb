#!/usr/bin/env ruby
require 'socket'

PORT = 843
Thread.abort_on_exception = true

class PolicyFileServer
  def start
    TCPServer.open(PORT) {|gs|
      loop do
        Thread.start(gs.accept) {|s|
          s.write "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0"
        }
      end
    }
  end
end

PolicyFileServer.new.start

