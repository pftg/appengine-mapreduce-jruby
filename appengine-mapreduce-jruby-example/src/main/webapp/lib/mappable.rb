module AppEngine::Mappable
  def self.included(base)
    #base.property :name, String
    base.extend ClassMethods
  end

  module ClassMethaods
    def async_map &block
      job = AppEngine::MapReduce::Job.new(:input_kind => name || storage_names[:default])
      job.map = block
      job.run
    end
  end
end
