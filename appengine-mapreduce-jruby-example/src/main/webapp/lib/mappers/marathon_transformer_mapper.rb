require 'appengine-apis/logger'
require 'appengine-apis/datastore'

require 'zlib'
require 'json'

require 'lib/marathon_extractor'

module MarathonTransformerMapper
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
    records = JSON.parse(page[:records].to_s)
  rescue => e
    logger.error "Catch exception: #{e.message}\n#{e.backtrace}"
  end


#  class <<self
#    def transform created_at, *records
#      logger.info "Transform extracted records"
#      logger.debug "JSON parsed #{records.size} competitions"
#
#      records.each do |record|
#        c = get_or_create_by(Competition, {:name => record['name']})
#
#        !record['games'] || record['games'].each do |game|
#          time = DateTime.strptime("#{game['date']} #{game['time']}", '%d/%m %H:%M').to_time
#          g = get_or_create_by c.games, {:time => time, :home => game['home'], :guest => game['guest']}
#
#          keys = %w(home guest time date)
#          attrs = game.reject { |k, v| keys.include? k }
#
#          %w(f1 f2).each do |p|
#            attrs[p], attrs["#{p}_fora"] = attrs[p].match(/([+-]?\d+\.\d+)=>(\d+\.\d+)/)[1..-1] if attrs[p]
#          end
#
#          attrs.each { |k, v| attrs[k] = v.to_f }
#
#          o = get_or_create_by(g.odds, {:actual_at => created_at}, attrs)
#
#          Analyzer::GameAnalyzer.new.send_later :next_analyze_for_game, o[:id]
#        end
#      end
#    end
#
#    def get_or_create_by klass, attrs, values = nil
#      (klass.first(attrs) || klass.create(values ? attrs.merge(values) : attrs))
#    end
#  end
end
