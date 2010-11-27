require 'datamapper'
DataMapper.setup(:default, 'appengine://auto')

require 'lib/mappable'

class Job
  include DataMapper::Resource

  property :id, Serial
  property :title, String, :required => true
  property :code, Text, :required => true
  property :input, Blob

  def activate *params
    logger.debug "Activate job at #{Time.now}: #{title}."
    eval(code)
  rescue => e
    logger.debug "Exception #{e.inspect}"
    logger.error e.message
  ensure
    logger.debug "Job finished at #{Time.now}!"
  end

  def logger
    @logger ||= AppEngine::Logger.new
  end

  def perform
    activate []
  end

  def display_name
    title
  end

  def enqueue *params
    Delayed::Job.enqueue self
  end
end


class ScrapedPage
  include DataMapper::Resource
  include AppEngine::Mappable

  storage_names[:default] = 'ScrapedPage'

  property :id, Serial

  property :extracted_at, Time
  property :created_at, Time
  property :updated_at, Time
  property :transformed_at, Time


  property :zipped, Boolean

  property :body, Blob
  property :converted_body, Blob
  property :extracted_records, Blob
end
