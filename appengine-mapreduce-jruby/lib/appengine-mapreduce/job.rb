require 'appengine-apis/labs/taskqueue'
require File.join(File.dirname(__FILE__), 'proc_source')
require File.join(File.dirname(__FILE__), 'string_helpers')

module AppEngine
  module MapReduce
    JRUBY_PROXY_MAPPER_CLASS = "com.jetthoughts.appengine.tools.mapreduce.JRubyMapper"

    BLOBSTORE_INPUT_FORMAT = "com.google.appengine.tools.mapreduce.BlobstoreInputFormat"
    DATASTORE_INPUT_FORMAT = "com.google.appengine.tools.mapreduce.DatastoreInputFormat"

    OUTPUT_ENTITY_KIND_KEY = "mapreduce.mapper.outputformat.datastoreoutputformat.entitykind"
    MAPREDUCE_SCRIPT_KEY = "mapreduce.ruby.script"

    CALLBACK_KEY = "mapreduce.appengine.donecallback.url"

    import com.google.appengine.tools.mapreduce.ConfigurationXmlUtil
    import com.google.appengine.tools.mapreduce.DatastoreInputFormat

    import com.jetthoughts.appengine.tools.mapreduce.JRubyMapper

    class Job
      attr_accessor :map, :reduce, :input_kind, :output_kind, :properties, :input_class

      def initialize options = {}
        @properties = {}

        %w(map reduce input_class input_kind output_kind).each do |attr_n|
          key = (attr_n.to_sym rescue attr_n) || attr_n
          self.send("#{attr_n}=", options.delete(key)) if options[key]
        end

        @properties["mapreduce.map.class"] = JRUBY_PROXY_MAPPER_CLASS

      end

      def run
        queue = AppEngine::Labs::TaskQueue

        queue.add({:method => 'POST',
                  :params => {'configuration' => conf_as_string},
                  :url => "/mapreduce/start"})
      end

      def input_kind= aKind
        @properties[DatastoreInputFormat::ENTITY_KIND_KEY] = aKind
      end

      def output_kind= aKind
        @properties[OUTPUT_ENTITY_KIND_KEY] = aKind
      end

      def map &block
        if block
          self.map = block
        end
        
        @properties[MAPREDUCE_SCRIPT_KEY]
      end

      def map= aMap
        if aMap.is_a?(Proc)
          aMap = serialize_block aMap
        end

        @properties[MAPREDUCE_SCRIPT_KEY] = aMap
      end

      def input_class= klass
        @properties["mapreduce.inputformat.class"] = klass
      end

      def use_blobstore_input_class
        self.input_class = BLOBSTORE_INPUT_FORMAT
      end

      def self.create_job_for mapper_name
        map = <<MAP
require 'lib/mappers/#{mapper_name.to_s}_mapper'
include #{mapper_name.to_s.camelize}Mapper
MAP
        Job.new(:map => map)
      end

      protected
      def conf_as_string
        @conf = JRubyMapper.createConfiguration
        @properties.each {|k,v| @conf.set(k, v)}
        ConfigurationXmlUtil.convertConfigurationToXml(@conf)
      end

      def serialize_block block
        <<MAP
self.class.class_eval do
  define_method(:map, lambda{ #{ProcSource.handle(block)} })
end
MAP
      end
    end
  end
end
