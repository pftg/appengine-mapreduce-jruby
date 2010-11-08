module AppEngine
  module MapReduce
    import com.google.appengine.tools.mapreduce.DatastoreInputFormat

    class DatastoreInputFormat
      attr_accessor :kind

      def initialize kind
        self.kind = kind
      end

      def to_conf_properties 
        { DatastoreInputFormat::ENTITY_KIND_KEY => kind }
      end
    end
  end
end
