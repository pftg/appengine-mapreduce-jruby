module AppEngine
  module Mappable
    def self.included(base)
      #base.property :name, String
      base.extend ClassMethods
    end

    module ClassMethods
      def async_map name = nil, &block
        default_name = DataMapper.repository.adapter.kind(self)
        job = AppEngine::MapReduce::Job.new(:input_kind => name || default_name)
        job.map = block
        job.run
      end
    end
  end
end
