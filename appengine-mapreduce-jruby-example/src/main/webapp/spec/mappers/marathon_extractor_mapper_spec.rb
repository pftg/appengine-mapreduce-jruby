require File.join(File.dirname(__FILE__), '..','spec_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'mappers', 'marathon_extractor_mapper')

require 'appengine-apis/datastore'
require 'appengine-apis/logger'

describe MarathonExtractorMapper do
  before :all do
    @entity = AppEngine::Datastore::Entity.new('Kind', 'KindKey')
    @entity[:converted_body] = AppEngine::Datastore::Blob.new(
            Zlib::Deflate.deflate('content', Zlib::BEST_COMPRESSION))
    @context = stub('context')
    @mutation_pool = stub('MutationPool')
    @context.stub(:getMutationPool).and_return(@mutation_pool)
  end

  describe '#map' do
    it 'should invoke extract_odds' do
      extractor = MarathonExtractor.new(nil)
      MarathonExtractor.should_receive(:new).and_return(extractor)
      extractor.should_receive(:extract_odds).with("content").and_return([])
      MarathonExtractorMapper.map(@entity.key, @entity, @conext).should
    end

    it 'should create new entity for results' do
      extractor = MarathonExtractor.new(nil)
      MarathonExtractor.should_receive(:new).and_return(extractor)
      extractor.should_receive(:extract_odds).with("content").and_return([{:games => []}])

      @result_entity = stub('result_entity')
      AppEngine::Datastore::Entity.should_receive(:new).with('MarathonExtractionResult').and_return(@result_entity)
      @result_entity.should_receive(:[]=).with(:records, "[{\"games\":[]}]")
      @result_entity.should_receive(:[]=).with(:status, "ok")

      @context.should_receive(:getMutationPool).and_return(@mutation_pool)
      @mutation_pool.should_receive(:put).with(@result_entity).and_return(true)
      MarathonExtractorMapper.map(@entity.key, @entity, @context).should
    end

    it "should save error message on extract errors" do
      extractor = MarathonExtractor.new(nil)
      MarathonExtractor.should_receive(:new).and_return(extractor)
      extractor.should_receive(:extract_odds).with("content").and_throw(:parse_exception)

      @result_entity = stub('result_entity')
      AppEngine::Datastore::Entity.should_receive(:new).with('MarathonExtractionResult').and_return(@result_entity)
      @result_entity.should_receive(:[]=).with(:message, "uncaught throw `parse_exception'")
      @result_entity.should_receive(:[]=).with(:status, "error")

#      @mutation_pool.should_receive(:put).with(@result_entity).and_return(true)
      MarathonExtractorMapper.map(@entity.key, @entity, @context).should

    end
  end
end
