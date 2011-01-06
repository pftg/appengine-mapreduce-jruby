require 'sinatra'

require 'appengine-apis/datastore'

# Configure DataMapper to use the App Engine datastore 
DataMapper.setup(:default, "appengine://auto")

class PageURL
  include DataMapper::AppEngineResource
  include AppEngine::Mappable

  property :url, Link

  has :n, :pages
end

class Page
  include DataMapper::AppEngineResource
  include AppEngine::Mappable

  property :body, Text

  belongs_to_entity :page_url
  timestamps :at 
end

get '/' do
end

get '/page_urls' do
  PageURL.create(params[:page_url])
  PageURL.create :url => 'http://mail.ru'
  PageURL.create :url => 'http://jetthoughts.com'
  PageURL.all.to_a.inspect
end

get '/download_pages' do
  PageURL.async_map do |k, v, c|
    require 'appengine-apis/urlfetch'
    v.pages.create(:body => AppEngine::URLFetch.fetch(v.url))
  end
end
