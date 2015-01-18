#!env ruby
# coding: utf-8
# Copyright (c) 2015 Sunao Hara, Okayama University

require 'socket'

class Junius::JuliusAdinnet
  DEFAULT_ADDR = "127.0.0.1"
  DEFAULT_PORT = 5530

  SIZEOF_INT = 4
  
  # サーバから送られてくるコマンド
  JAPI_REQUEST_PAUSE  = 0
  JAPI_REQUEST_RESUME = 1
  JAPI_REQUEST_TERMINATE = 2

  # adin接続先のエンジン内部状態
  JULIUS_STATUS_SLEEP  = 0
  JULIUS_STATUS_ACTIVE = 1
  
  def initialize
    @sock = nil
    @adin_status = -1

    @read_thread = nil
    @request_stop = false
  end
  
  def read
    lines = []
    while !@sock.nil? && !@request_stop
      rs = IO.select([@sock], [], [], 1) # 4th param = Timeout[s]
      next if rs.nil?

      begin
        data = adinnet_rt
      rescue => exc
        $stderr.puts "DEBUG: ADIN_RT: EXCEPTION: #{exc}"
        return false
      end
      return false if data.nil?
      
      case data
      when JAPI_REQUEST_PAUSE
        @adin_status = JULIUS_STATUS_SLEEP
      when JAPI_REQUEST_RESUME
        @adin_status = JULIUS_STATUS_ACTIVE
      when JAPI_REQUEST_TERMINATE
        @adin_status = JULIUS_STATUS_SLEEP
      end

      #return true
    end
  end

  def adinnet_rt
    d = @sock.recv(SIZEOF_INT)
    return nil if d.nil?

    len_a = d.unpack('V') # V = 32bit, little endian
    return nil if len_a[0].nil?

    data = @sock.recv( len_a[0] )
    $stderr.puts "DEBUG: ADIN_RT: RECV(#{len_a[0]}): #{data}"

    return data
  end

  def adinnet_wt(data)
    @sock.write( [data.length].pack('V') ) # V = 32bit, little endian
    @sock.write( data ) unless data.empty? # N = Big endian
  end
  
  def adinnet_wt_end_of_segment
    adinnet_wt([])
  end

  def connect_server (host_addr = DEFAULT_ADDR, host_port = DEFAULT_PORT)
    $stderr.puts "INFO: ADINNET: Connect: #{host_addr}:#{host_port}"

    begin
      @sock = TCPSocket.open(host_addr, host_port)
      @adin_status = JULIUS_STATUS_ACTIVE
    rescue
      puts "TCPSocket.open failed : #$!\n"
      return false
    end

    @read_thread = Thread.start {
      $stderr.puts "DEBUG: ADIN_PROCESS: Start."
      while read
        $stderr.puts "DEBUG: ADIN_LOOP"
      end
      $stderr.puts "DEBUG: ADIN_PROCESS: Finish."
    }
    return true
  end
  
  def send_rawfile_le (filename)
    f = open(filename, "r").binmode
    
    while d = f.read(4096)
      adinnet_wt(d)
      sleep 0.05
    end
    adinnet_wt_end_of_segment
    
  end
  
  def test_senddata
    send_rawfile_le("test.le")
  end

  def disconnect_server
    $stderr.puts "DEBUG: ADIN: disconnect: start"
    @read_thread.join
    @sock.close
    $stderr.puts "DEBUG: ADIN: disconnect: end"
  end
end
