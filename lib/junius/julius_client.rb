#!env ruby
# coding: utf-8
# Copyright (c) 2015 Sunao Hara, Okayama University

require 'socket'

require 'junius/julius_default_xml_parser.rb'

class Junius::JuliusClient
  DEFAULT_ADDR = "127.0.0.1"
  DEFAULT_PORT = 10500
  
  def initialize(xml_parser = nil)

    @sock = nil
    @read_thread = nil
    @request_stop = false
    if xml_parser.nil?
      @xml_parser = Junius::JuliusDefaultXmlParser.new
    else
      @xml_parser = xml_parser
    end
  end
  
  def shift_result
    cnt = 0
    result = nil
    while @xml_parser.results.empty?
      return nil if cnt > 100 # 100 = 10sec
      cnt = cnt + 1
      sleep 0.1
    end
    return @xml_parser.results.shift # this is @sentences
  end
  
  def read
    lines = []
#    until @sock.nil?
    while !@sock.nil? && !@request_stop
      rs = IO.select([@sock], [], [], 1)
      next if rs.nil?
      begin
        line = @sock.gets
        unless line then
          return false
        end
        unless line[0] == '.'
          lines << line.chomp
        else
          puts '[' + lines.join('') + ']'
          
          #r = JuliusRecogOut.new
          #REXML::Parsers::StreamParser.new(lines.join(''), r).parse
          REXML::Parsers::StreamParser.new(lines.join(''), @xml_parser).parse
          
          lines = []
          return true
        end
      rescue => exc
        $stderr.puts exc
        return false
      end
    end
    
  end
  
  def connect_server (host_addr = DEFAULT_ADDR, host_port = DEFAULT_PORT)
    $stderr.puts "INFO: JCLIENT: Connect: #{host_addr}:#{host_port}"
    begin
      @sock = TCPSocket.open(host_addr, host_port)
    rescue
      puts "TCPSocket.open failed : #$!\n"
    else
      @sock.set_encoding 'utf-8'
      @read_thread = Thread.start {
        $stderr.puts "DEBUG: JCLIENT_PROCESS: Start."
        while read
          $stderr.puts "DEBUG: JCLIENT_LOOP"
          Thread.pass
        end
        $stderr.puts "DEBUG: JCLIENT_PROCESS: Finish."
      }
      Thread.pass
      $stderr.puts "DEBUG: JCLIENT_PROCESS: Thread ready"
      
    end
  end

  def disconnect_server
    $stderr.puts "DEBUG: JCLIENT: disconnect: start"
    @request_stop = true
    @read_thread.join
    @sock.close
    $stderr.puts "DEBUG: JCLIENT: disconnect: end"
  end

=begin
/* japi_misc.c */
void japi_die(int);
void japi_get_version(int);
void japi_get_status(int);
void japi_pause_recog(int);
void japi_terminate_recog(int);
void japi_resume_recog(int);
void japi_set_input_handler_on_change(int, char *);
=end
  def request_die
    $stderr.puts "DEBUG: JCLIENT: REQUEST_DIE"
    @sock.write("DIE\n")
  end
  def request_version
    @sock.write("VERSION\n")
  end
  def request_status
    @sock.write("STATUS\n")
  end
  def request_pause_recog
    @sock.write("PAUSE\n")
  end
  def request_terminate_recog
    @sock.write("TERMINATE\n")
  end
  def request_resume_recog
    @sock.write("RESUME\n")
  end
  def request_set_input_handler_on_change
    # ToDo: Implementation
    raise "Not implemented."
  end

=begin
/* japi_grammar.c */
void japi_get_graminfo(int sd);
void japi_change_grammar(int sd, char *prefixpath);
void japi_add_grammar(int sd, char *prefixpath);
void japi_delete_grammar(int sd, char *idlist);
void japi_activate_grammar(int sd, char *idlist);
void japi_deactivate_grammar(int sd, char *idlist);
void japi_sync_grammar(int sd);
void japi_add_words(int sd, char *idstr, char *dictfile);
=end
  def request_get_graminfo
      @sock.write("GRAMINFO\n")
  end
  def request_sync_grammar
      @sock.write("SYNCGRAM\n")
  end

=begin
/* japi_process.c */
void japi_list_process(int sd);
void japi_current_process(int sd, char *pname);
void japi_shift_process(int sd);
void japi_add_process(int sd, char *jconffile);
void japi_del_process(int sd, char *pname);
void japi_activate_process(int sd, char *pname);
void japi_deactivate_process(int sd, char *pname);
=end
  def request_list_process
      @sock.write("LISTPROCESS\n")
  end
  def request_current_process
    # ToDo: Implementation
    raise "Not implemented."
  end
  def request_shift_process
    # ToDo: Implementation
    raise "Not implemented."
  end
  def request_add_process
    # ToDo: Implementation
    raise "Not implemented."
  end
  def request_del_process
    # ToDo: Implementation
    raise "Not implemented."
  end
  def request_activate_process
    # ToDo: Implementation
    raise "Not implemented."
  end
  def request_deactivate_process
    # ToDo: Implementation
    raise "Not implemented."
  end
  
end
