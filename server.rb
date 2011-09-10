#!/usr/bin/env ruby
require "socket"

Thread.abort_on_exception

class Member
  attr_reader :name
  attr_accessor :team
  def initialize(sock, name)
    @sock = sock
    @name = name
    @team = 0
  end

  def send(str)
    @sock.puts str
  end
end

class SocketServer
  def initialize(port = 4444)
    @port = port
    @connect ||= []
  end

  def open
    TCPServer.open(@port) {|gs|
      puts "Chat Server was started in port #{@port}."

      while true
        Thread.start(gs.accept) {|s|
          yield(s)
        }
      end
    }
  end

  def start
    open {|s|
      name = s.gets.chomp
      mem = Member.new(s, name)
      add_connection(mem)
      show_connection
      # show_team

      while str = s.gets
        str.chomp!
        if /^teamdiv$/ =~ str
          team_div
          show_team
        else
          send_message(name, str)
        end
      end

      delete_connection mem
      show_connection
    }
  end

  def send_message(name, str)
    puts "> #{name}: #{str}"
    send_all "> #{name}: #{str}"
  end

  def send_all(str)
    @connect.each do |mem|
      mem.send(str)
    end
  end

  def add_connection(mem)
    @connect.push mem
    puts "#{mem.name} connected."
    # send_all "#{mem.name} connected."
  end

  def delete_connection(mem)
    @connect.delete mem
    puts "#{mem.name} disconnected."
    # send_all "#{mem.name} disconnected."
    if @connect.size == 0
      exit
    end
  end

  def show_connection
    p @connect
    send_all "MEMBERS"
    send_all @connect.map{|mem| mem.name}
  end

  def show_team
    send_all "-----Team A-----"
    send_all @connect.select{|mem| mem.team == 1}.map{|mem| mem.name}
    send_all "-----Team B-----"
    send_all @connect.select{|mem| mem.team == 2}.map{|mem| mem.name}
    send_all "----------------"
  end

  def team_div
    arr = member_shuffle
    arr[0].each do |mem|
      mem.team = 1
    end
    arr[1].each do |mem|
      mem.team = 2
    end
  end

  def member_shuffle
    size = @connect.size
    team_a = []
    team_b = []
    # ceil ... (A + B + 1) / B
    size_a = (size + 2 - 1) / 2
    size_b = size / 2
    que = @connect.shuffle
    size.times do
      sum = size_a + size_b
      if rand <= size_a / sum.to_f
        team_a.push que.pop
        size_a -= 1
      else
        team_b.push que.pop
        size_b -= 1
      end
    end

    [team_a, team_b]
  end
end

server = SocketServer.new
server.start

