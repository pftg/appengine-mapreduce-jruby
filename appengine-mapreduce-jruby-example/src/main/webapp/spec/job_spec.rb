require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'job')

describe AppEngine::MapReduce::Job do
  describe '#map' do
    it 'should create map tasks from block' do
      subject.
        map{ |k, v, ctx| puts 'test' }.
        should == "self.class.class_eval do\n  define_method(:map, lambda{ |k, v, ctx| puts 'test' })\nend\n"
    end

    it 'should create map from lambda' do
      subject.map = lambda { |k, v, ctx| puts 'test' }
      subject.map.should == "self.class.class_eval do\n  define_method(:map, lambda{ |k, v, ctx| puts 'test' })\nend\n"
    end

    it 'should create map tasks as string' do
      subject.map = "puts 'test'"
      subject.map.should == "puts 'test'"
    end
  end # describe '#map'

  describe "create_job_for" do
    subject { AppEngine::MapReduce::Job.create_job_for :marathon_extractor }

    it 'should generate map scriptlet' do
      subject.map.should == <<MAP
require 'lib/mappers/marathon_extractor_mapper'
include MarathonExtractorMapper
MAP
    end
  end
end
