require 'appengine-apis/labs/taskqueue'

module AppEngine
  module MapReduce
    import com.google.appengine.tools.mapreduce.ConfigurationXmlUtil
    import com.google.appengine.tools.mapreduce.DatastoreInputFormat

    import com.jetthoughts.appengine.tools.mapreduce.JRubyMapper

    class Job
      attr_accessor :map, :reduce, :input_kind

      def initialize options = nil
        @conf = JRubyMapper.createConfiguration
        options ||= {}

        [:map, :reduce, :input_kind].each do |attr_n|
          self.send("#{attr_n}=", options.delete(attr_n) || "")
        end

      end

      def run
        queue = AppEngine::Labs::TaskQueue

        queue.add({:method => 'POST',
                   :params => {'configuration' => conf_as_string},
                   :url => "/mapreduce/start"})
      end

      protected
      def conf_as_string
        @conf.set(DatastoreInputFormat::ENTITY_KIND_KEY, input_kind)
        ConfigurationXmlUtil.convertConfigurationToXml(@conf)
      end
    end
  end
end