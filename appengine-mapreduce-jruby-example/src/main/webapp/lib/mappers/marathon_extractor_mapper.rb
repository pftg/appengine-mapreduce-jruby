require 'appengine-apis/logger'
require 'appengine-apis/datastore'

require 'zlib'
require 'json'

require 'lib/marathon_extractor'

module MarathonExtractorMapper
  def self.logger
    @@logger ||= AppEngine::Logger.new
  end

  def self.output_kind context
    context.getConfiguration.get("mapreduce.mapper.outputformat.datastoreoutputformat.entitykind")
  end

  def self.create_result_entity context
    AppEngine::Datastore::Entity.new(output_kind(context))
  end

  def self.map key, value, context
    result_entity = create_result_entity(context)
    result_entity[:page] = value

    begin
      marathon_odds_page =  Zlib::Inflate.inflate(value[:converted_body])
      extractor = MarathonExtractor.new(nil)
      extractor.logger = logger
      records = extractor.extract_odds(marathon_odds_page)

      result_entity[:records] = AppEngine::Datastore::Text.new(records.to_json)
      result_entity[:status] = 'ok'
    rescue => e
      logger.warn "#{e.message} in #{e.backtrace}"

      result_entity[:message] = AppEngine::Datastore::Text.new(e.message)
      result_entity[:status] = 'error'
    end


    context.getMutationPool.put result_entity
  rescue => e
    logger.error "Catch exception: #{e.message}\n#{e.backtrace}"
  end
end
