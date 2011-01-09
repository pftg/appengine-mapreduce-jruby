require 'sinatra'

require 'appengine-apis/datastore'

require 'models'

require 'haml'
set :haml, :format => :html5

get '/page_urls' do
  @page_urls = PageURL.all
  haml :index
end

post '/page_urls' do
  PageURL.create!(params[:page_url])
  redirect '/page_urls'
end

get '/download_pages' do
  PageURL.async_map do |k, v, c|

    require 'rubygems'

    require 'appengine-apis/urlfetch'
    require 'appengine-apis/datastore'

    return unless v[:url]

    require "bundler"
    Bundler.setup(:default, :development)

    require 'models'

    page_url = PageURL.get(k)

    puts "Download URL: #{v[:url]}"
    puts body = AppEngine::URLFetch.fetch(v[:url]).body
    page_url.pages.create :body => body
  end
end
