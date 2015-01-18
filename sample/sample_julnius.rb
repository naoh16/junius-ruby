#!env ruby
# coding: utf-8

$LOAD_PATH.unshift './lib'

require 'junius'


jc = Junius::JuliusClient.new
jc.connect_server
sleep 1

ja = Junius::JuliusAdinnet.new
ja.connect_server

$stderr.puts "Status check"
jc.request_status
sleep 2

ja.send_rawfile_le("test.le")
sleep 2

$stderr.puts "Wait result !!"
$stderr.puts jc.shift_result

#$stderr.puts "Status check"
#jc.request_status
#sleep 2

#$stderr.puts "Request Pause"
#jc.request_pause_recog
#$stderr.puts "Request Terminate"
#jc.request_terminate_recog
#sleep 2
#jc.request_status
#sleep 2

#$stderr.puts "Request Resume"
#jc.request_resume_recog
#sleep 2
#jc.request_status
#sleep 2

#sleep 2
#jc.request_terminate_recog
#sleep 2
#jc.request_die
#sleep 2

ja.disconnect_server
jc.disconnect_server
