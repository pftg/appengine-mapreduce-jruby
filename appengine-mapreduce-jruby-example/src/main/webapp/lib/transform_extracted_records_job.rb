class TransformExtractedRecordsJob

  attr_reader :logger

  def initialize logger = nil
    @logger = logger || AppEngine::Logger.new
  end

  def activate
    begin
      last_created_at = get_last_processed_time

      query = AppEngine::Datastore::Query.new('ScrapedPage').sort('extracted_at')

      if last_created_at
        query.filter(:extracted_at, AppEngine::Datastore::Query::Constants::GREATER_THAN, last_created_at)
      else
        logger.debug "There is no saved last extracted page updated at value"
      end

      page = query.fetch(:limit => 1).first

      unless page
        return warn_message "There are no pages"
      end

      if page[:transformed_at]
        return warn_message "Page [#{page.id}] already has been transformed", page[:transformed_at]
      end

      logger.info "Start transformation extracted recirdse [#{page.id}], created at #{page[:created_at]} "

      created_at = page[:created_at]
      records = JSON.parse(page[:extracted_records].to_s)
  
      t_records = records.each do |record|
        Delayed::Job.enqueue TransformPerfomer.new(created_at, record) 
      end

      #t_records = transform(created_at, *records)

      save(page)

      set_last_processed_time(page)

      return "Transformed successful #{t_records.size}"
    rescue => e
      return warn_message "Error in #{page ? page.key : nil}:\n#{e.message}", page ? page[:transformed_at] : nil
    end
  end

  def get_memcache
    @memcache ||= AppEngine::Memcache.new
  end

  def get_last_processed_time
    get_memcache.get(:last_processed_records_extracted_at)
  end

  def set_last_processed_time page
    time = page.is_a?(Time) ? page : page[:extracted_at]
    get_memcache.set(:last_processed_records_extracted_at, time)
  end

  def save page
    page[:transformed_at] = Time.now
    AppEngine::Datastore.put page
  end

  def transform created_at, *records
    logger.info "Transform extracted records" 
    logger.debug "JSON parsed #{records.size} competitions" 

    records.each do |record|
      c = get_or_create_by(Competition, {:name => record['name']})

      !record['games'] || record['games'].each do |game|
        time = DateTime.strptime("#{game['date']} #{game['time']}", '%d/%m %H:%M').to_time
        g = get_or_create_by c.games, {:time => time, :home => game['home'], :guest => game['guest']}

        keys = %w(home guest time date)
        attrs = game.reject{|k, v| keys.include? k}

        %w(f1 f2).each do |p|
          attrs[p], attrs["#{p}_fora"] = attrs[p].match(/([+-]?\d+\.\d+)=>(\d+\.\d+)/)[1..-1] if attrs[p]
        end

        attrs.each{|k, v| attrs[k] = v.to_f}

        o = get_or_create_by(g.odds, {:actual_at => created_at}, attrs)

        transaction = AppEngine::Datastore.begin_transaction
        Analyzer::GameAnalyzer.new.send_later :next_analyze_for_game, o[:id]
        transaction.commit
      end
    end
  end

  def get_or_create_by klass, attrs, values = nil
    transaction = AppEngine::Datastore.begin_transaction
    result = klass.first(attrs) || klass.create(values ? attrs.merge(values) : attrs)
    transaction.commit
    result
  end

  def warn_message message, time = nil, transaction = nil
    logger.warn(message)
    set_last_processed_time(time) if time
    transaction.rollback if transaction
    return  message
  end
end

class TransformPerfomer < Struct.new(:created_at, :record)
  def perform
    TransformExtractedRecordsJob.new.transform created_at, record
  end
end
