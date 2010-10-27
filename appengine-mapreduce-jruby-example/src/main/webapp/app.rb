require 'sinatra'
require 'appengine-mapreduce/job'
require 'appengine-apis/datastore'

require 'base64'
require 'zlib'

get '/' do
  "Hello"
end

post '/run' do
  job = AppEngine::MapReduce::Job.new({:input_kind => "PBFVotes"}.merge(params))
  job.run
  redirect '/mapreduce/status'
end


get '/scraped_page' do
  entry = AppEngine::Datastore::Query.new('ScrapedPage').fetch(:limit => 1)

  Zlib::Inflate.inflate(Base64.decode64(entry.first['converted_body']))
end