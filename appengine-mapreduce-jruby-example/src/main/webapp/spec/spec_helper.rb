require 'rubygems'

begin
  # Install stubs and environment
  require 'appengine-apis/testing'
  AppEngine::Testing.boot
  require 'appengine-apis/urlfetch'
  require 'appengine-apis/tempfile'
rescue Exception => e
  puts e.inspect
  puts e.backtrace
end

require File.join(File.dirname(__FILE__), 'mapreduce_stubs')
