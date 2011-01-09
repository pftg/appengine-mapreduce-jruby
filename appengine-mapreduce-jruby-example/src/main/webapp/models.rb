require 'datamapper'

require 'appengine-mapreduce/job'
require 'appengine-mapreduce/mappable'


DataMapper.setup(:default, "appengine://auto")

# Configure DataMapper to use the App Engine datastore
class PageURL
  include DataMapper::AppEngineResource
  include AppEngine::Mappable

  property :url, Link

  has n, :pages
end

class Page
  include DataMapper::AppEngineResource
  include AppEngine::Mappable

  property :body, Text

  belongs_to_entity :page_url
  timestamps :at
end
