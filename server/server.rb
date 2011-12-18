#!/usr/bin/env ruby
#
# = チーム分けサーバーの本体となるクラス
# Author:: arosh
#
require "socket"

AUTO_EXIT = false
Thread.abort_on_exception = true

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

  def inspect
    "#<@name=\"#{name}\", @team=#{team}>"
  end
end

class SocketServer
  def initialize(port = 7650)
    @port = port
    @connect = []
    @mut = Mutex.new
  end

  def open(s)
    name = s.gets.chomp
    mem = Member.new(s, name)
    add_connection(mem)
    show_connection

    while str = s.gets
      str.chomp!
      if /^group$/ =~ str
        team_div
      else
        send_message(name, str)
      end
    end

    delete_connection mem
    show_connection
  end

  def start
    TCPServer.open(@port) {|gs|
      puts "Grouping Server was started in port #{@port}."

      loop do
        Thread.start(gs.accept) {|s|
          open(s)
        }
      end
    }
  end

  def send_message(name, str)
    puts "> #{name}: #{str}"
    send_all "> #{name}: #{str}"
  end

  def send_all(str)
    @mut.synchronize {
      @connect.each do |mem|
        mem.send(str)
      end
    }
  end

  def add_connection(mem)
    @mut.synchronize {
      @connect << mem
      puts "#{mem.name} connected."
    }
  end

  def delete_connection(mem)
    @mut.synchronize {
      @connect.delete mem
      puts "#{mem.name} disconnected."

      if AUTO_EXIT && @connect.size == 0
        exit
      end
    }
  end

  def show_connection
    send_string = "MEMBERS" 

    @mut.synchronize {
      p @connect

      @connect.each do |mem|
        send_string << "\n#{mem.name}"
      end
    }

    send_all(send_string)
  end

  def show_team(arr)
    send_string = "GROUP"

    arr[0].each do |mem|
      send_string << "\n#{mem.name} A"
    end

    arr[1].each do |mem|
      send_string << "\n#{mem.name} B"
    end

    send_all(send_string)
  end

  def team_div
    arr = member_shuffle

    arr[0].each do |mem|
      mem.team = 1
    end

    arr[1].each do |mem|
      mem.team = 2
    end

    show_team(arr)
  end

  def member_shuffle
    size = 0
    que = []
    @mut.synchronize {
      size = @connect.size
      que = @connect.shuffle
    }
    team_a = []
    team_b = []
    # ceil ... (A + B - 1) / B
    size_a = (size + 2 - 1) / 2
    size_b = size / 2

    size.times do
      sum = size_a + size_b

      if rand <= size_a / sum.to_f
        team_a << que.pop
        size_a -= 1
      else
        team_b << que.pop
        size_b -= 1
      end
    end
    team_a = que[0, size_a]
    team_b = que[size_a, size_b]

    [team_a, team_b]
  end
end

SocketServer.new.start

