require 'appengine-apis/labs/taskqueue'

module AppEngine
  module MapReduce
    BLOBSTORE_INPUT_FORMAT = "com.google.appengine.tools.mapreduce.BlobstoreInputFormat"
    DATASTORE_INPUT_FORMAT = "com.google.appengine.tools.mapreduce.DatastoreInputFormat"

    OUTPUT_ENTITY_KIND_KEY = "mapreduce.mapper.outputformat.datastoreoutputformat.entitykind"

    CALLBACK_KEY = "mapreduce.appengine.donecallback.url"
    
    import com.google.appengine.tools.mapreduce.ConfigurationXmlUtil
    import com.google.appengine.tools.mapreduce.DatastoreInputFormat

    import com.jetthoughts.appengine.tools.mapreduce.JRubyMapper

    class Job
      attr_accessor :map, :reduce, :input_kind, :output_kind, :properties, :input_class

      def initialize options = {}
        puts "Job Options: #{options.inspect}"

        @properties = {}

        %w(map reduce input_class input_kind output_kind).each do |attr_n|
          self.send("#{attr_n}=", options.delete(attr_n)) if options[attr_n]
        end

        @properties["mapreduce.map.class"] = "com.jetthoughts.appengine.tools.mapreduce.JRubyMapper"

      end

      def run
        queue = AppEngine::Labs::TaskQueue

        queue.add({:method => 'POST',
                  :params => {'configuration' => conf_as_string},
                  :url => "/mapreduce/start"})

        puts "Conf: #{conf_as_string}"
      end

      def input_kind= aKind
        @properties[DatastoreInputFormat::ENTITY_KIND_KEY] = aKind
      end

      def output_kind= aKind
        @properties[OUTPUT_ENTITY_KIND_KEY] = aKind
      end

      def map= aMap
        @properties["mapreduce.ruby.script"] = aMap
      end

      def input_class= klass
        @properties["mapreduce.inputformat.class"] = klass
      end

      def use_blobstore_input_class
        self.input_class = BLOBSTORE_INPUT_FORMAT
      end

      protected
      def conf_as_string
        @conf = JRubyMapper.createConfiguration
        @properties.each {|k,v| @conf.set(k, v)}
        ConfigurationXmlUtil.convertConfigurationToXml(@conf)
      end
    end
  end
end
