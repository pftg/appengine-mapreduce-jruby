require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'mappable')

class Resource
  include DataMapper::AppEngineResource
  include AppEngine::Mappable

  storage_names[:default] = '_Resource'
end

describe AppEngine::Mappable do
  describe '.included' do
    it "should add class method 'map'" do
      
    end
  end

  describe '#map' do
    context 'changed storage name' do

      it 'should return changed storage name' do

      end
    end
  end
end
