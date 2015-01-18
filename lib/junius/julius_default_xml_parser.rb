#!env ruby
# coding: utf-8
# Copyright (c) 2015 Sunao Hara, Okayama University

require "rexml/parsers/streamparser"
require "rexml/parsers/baseparser"
require "rexml/streamlistener"

class Junius::JuliusDefaultXmlParser
  include ::REXML::StreamListener
  
  attr_reader :results
#  attr_reader :sentences
#  attr_reader :has_new_result
  
  def initialize
    @results = []
    @sentences = []
    @words = []
#    @has_new_result = false
#    $stderr.puts "DEBUG: #{__FILE__}"
  end

  def tag_start(name, attrs)
    puts "DEBUG: tag_start:#{name}:" + attrs.to_s

    if name == "SHYPO"
      @words = []
    elsif name == "WHYPO"
      @words << attrs
    elsif name == "RECOGOUT"
      @sentences = []
#      @has_new_result = false
    end
  end

  def tag_end(name)
#    puts "DEUBG: tag_end:#{name}" unless name == "WHYPO"

    if name == "SHYPO"
      @sentences << @words
    elsif name == "RECOGOUT"
#      @has_new_result = true
      @results << @sentences
    end
  end
  
  #def text(text)
    #puts "text:[#{text}]"
  #end
end
