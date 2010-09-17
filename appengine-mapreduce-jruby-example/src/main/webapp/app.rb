require 'sinatra'
require 'appengine-mapreduce/job'

get '/' do
  "Hello"
end

get '/run' do
  job = AppEngine::MapReduce::Job.new :input_kind => "PBFVotes"
  job.run
  "Job have been added!"
end