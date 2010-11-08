require 'sinatra'

require 'appengine-apis/datastore'
require 'lib/job'

require 'base64'
require 'zlib'
require 'appengine-apis/urlfetch'

get '/' do
end

get '/scrapper' do
  hdoc = Net::HTTP.get(URI.parse("http://odds.marathonbet.com/odds-view.phtml?h=0&r0=0&r0=0&l=&m=1"))

  e = AppEngine::Datastore::Entity.new('ScrapedPage')

  e[:created_at] = Time.now
  e[:updated_at] = Time.now
  e[:converted_body] = AppEngine::Datastore::Blob.new(Zlib::Deflate.deflate(java.lang.String.new(hdoc.to_java_bytes, 'cp1251').to_s, Zlib::BEST_COMPRESSION))

  e[:zipped] = true

  AppEngine::Datastore.put e

  Zlib::Inflate.inflate(e[:converted_body].to_s)
end

get '/extract' do
  job_params = {
          'input_kind' => "ScrapedPage",
          "map"=> "require 'lib/mappers/marathon_extractor_mapper'; puts 'Marathon Extractor Mapper'; def map(k,v,c); p v; MarathonExtractorMapper.map(k,v,c); end\n"
  }

  AppEngine::MapReduce::Job.new(job_params).run

#  redirect '/mapreduce/status'

end

post '/run' do
  job = AppEngine::MapReduce::Job.new({'input_kind' => "PBFVotes"}.merge(params))
  job.run
  redirect '/mapreduce/status'
end

get '/scraped_page' do
  entry = AppEngine::Datastore::Query.new('ScrapedPage').fetch(:limit => 1)

  Zlib::Inflate.inflate(entry.first['converted_body'])
end