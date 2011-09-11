#!/usr/bin/env ruby
require 'socket'

Thread.abort_on_exception

class PolicyFileServer
  def start
    TCPServer.open(843) {|gs|
      while true
        Thread.start(gs.accept) {|s|
          s.write "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\"/></cross-domain-policy>\0"
        }
      end
    }
  end
end

