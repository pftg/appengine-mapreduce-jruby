require 'logger'

class MarathonExtractor

  attr_accessor :logger

  MAPPING = [:date, :home, :first, :draw, :second, :first_draw, :first_second, :draw_second, :f1, :f2, :total, :less, :more, :time, :guest]
  RESULTS = %w(Поб.1 НичьяX Поб.2 1X 12 X2 фора1=>кф1 фора2=>кф2 тотал мен. бол.)

  def self.bold s
    "<b>\\s*?#{s}\\s*?<\\/b>"
  end

  DATE_EXP = "(\\d\\d\\/\\d\\d)"
  HOME_EXP = "<b id=r.*?1\\)(?:.*?u>\\s*)?(.*?)\\s*(?:<\\/u>.*?)?<\\/b>"

  ODD_EXP = "(?:(?:<span class=tk>)?(\\d+\\.\\d+)(?:<\\/span>)?)"
  BOLD_ODD_EXP = bold("#{ODD_EXP}?")
  FIRST_ODD_EXP = BOLD_ODD_EXP

  UNITED_ODD_EXP = "\\s{0,6}#{ODD_EXP}?\\s{1,3}#{ODD_EXP}?\\s+"
  DRAW_AND_SECOND_ODDS_EXP = UNITED_ODD_EXP

  FIRST_DRAW_ODD_EXP = BOLD_ODD_EXP

  GUEST_EXP = "<b id=r.*?2\\)(?:.*?u>\\s*)?(.*?)\\s*(?:<\\/u>.*?)?<\\/b>"
  FORA_EXP = "([-+]?\\d+\\.\\d+=>\\d+\\.\\d+)"
  FORA_2_EXP = "\\s*#{FORA_EXP}?\\s*"
  BOLD_FORA_EXP = bold("#{FORA_EXP}?")
  TIME_EXP = "(\\d+:\\d+)\\s*"


  def self.build_regular_expr_for_odds_parsing
    p = {}

    p[:date] = DATE_EXP
    p[:home] = HOME_EXP
    p[:guest] = GUEST_EXP
    p[:total] = p[:first_draw] = p[:first] = BOLD_ODD_EXP
    p[:f1] = BOLD_FORA_EXP
    p[:f2] = FORA_2_EXP
    p[:time] = TIME_EXP
    p[:less_more] = p[:first_second_and_second_draw] = p[:draw_and_second] = UNITED_ODD_EXP

    matchers = [DATE_EXP, HOME_EXP, FIRST_ODD_EXP, DRAW_AND_SECOND_ODDS_EXP, FIRST_DRAW_ODD_EXP,
                p[:first_second_and_second_draw], p[:f1], p[:f2], p[:total], p[:less_more],
                p[:time], p[:guest]]

    result = "(?m:%s)" % matchers.join(".*?")
    return result
  end

  ODDS_MATCHER = self.build_regular_expr_for_odds_parsing
  GAME_DATA_CONTAINER_MATCHER = /<hr.*?<hr.*?>(.*?)<big.*?<\/big>/m
  #GAME_DATA_CONTAINER_MATCHER = /<hr .*?<hr .*?>(.*?)(<big|<hr)/m

  def initialize(resource_loader = nil, html_parser = nil)
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::ERROR

    @resource_loader = resource_loader
  end


  def extract_odds resource
    return nil unless resource

    @doc = resource
    @doc.gsub!("&gt;", ">")

#    @doc = @html_parser.parse(resource, nil, 'UTF-8')
    @logger.debug "Document loaded: #{@doc}"


    @logger.info("Extracting odds from odds-view.phtml page...")
    result = []

    competition_containers = get_competition_containers
    @logger.info "Found #{competition_containers.size} competition(s)."

    competition_containers.each do |competition_container|
      result << parse_competition(competition_container)
      @logger.info "Found '#{result.last[:name]}' competition."
    end

    @logger.info "Done."

    result
  end

  def parse_competition competition_container
    {
            :name => competition_container[0],
            :games => parse_games(competition_container[1])
    }
  end

  def parse_games_data_with_regexp (content)
    game_data_containers = find_game_data_containers(content)
    game_data_containers.collect do |game_data|
      extract_game_entity(game_data)
    end
  end


  def extract_game_entity(game_data)
    @logger.debug("-" * 100)
    @logger.debug("Extract game data from:\n#{game_data}")

    game_data_match = game_data.strip.match(ODDS_MATCHER)

    if game_data_match.nil?
      dump_trace_data(game_data)
      raise "Error in parsing: #{game_data.inspect}\n with expr:\n #{ODDS_MATCHER}"
    end

    matched_without_source = game_data_match[1..-1]

    Hash[*([MAPPING, matched_without_source].transpose.flatten)]
  end

  def dump_trace_data(game_data)
  end

  def find_game_data_containers(content)
    @logger.debug "With title: #{content}"

    match_game_data_containers = content.scan(GAME_DATA_CONTAINER_MATCHER)

    if match_game_data_containers.nil?
      raise "Error in find game data containers: #{content.inspect}\n with expr:\n #{GAME_DATA_CONTAINER_MATCHER}"
    end


    match_game_data_containers.collect do |containers|
      games_data_without_title = containers[0]
      @logger.debug "Without title: #{games_data_without_title.inspect}"
      games_data_without_title.scan(/\s+\d\d\/\d\d.*?2\).*?<\/b>\n/m)
    end.flatten
  end

  def parse_games_data (games_container)
    parse_games_data_with_regexp games_container
  end

  def accept_all_results(games_container)
    games_container_content = games_container

    !RESULTS.inject(false) { |acc, result|
      accept_result = games_container_content.include?(result)
      @logger.warn "Competition do not accept '#{result}' result!" unless accept_result

      acc || !accept_result
    }
  end

  def parse_games games_container
    @logger.debug(games_container)

    unless accept_all_results(games_container)
      @logger.warn "There are no useful results"
      @logger.debug "Inner text: #{games_container}"
      return nil
    end

    parse_games_data(games_container)
  end

  def find_first_sibling_pre_for_parent(element)
    #    element.search "/../following-sibling::pre[1]"
    "#{xpath_for(element)}/../following-sibling::pre[1]"
    #    "#{xpath_for(element)}/../following-sibling::pre[1]"
  end


  def get_competition_containers
    @doc.scan(/<div\s+class=cap>(.*?)<\/div>.*?<pre>(.*?)<\/pre>/mu)
  end

  def get_element_by_xpath(games_container_xpath)
    get_elements_by_xpath(games_container_xpath).first
  end

  def get_elements_by_xpath xpath
    result = @doc.search(xpath)
    #    result = @doc.xpath(xpath)
    @logger.debug "Result for #{xpath}:\n #{result.inspect}"
    result
  end

  def text(element)
    element.inner_text
    #    element.content
  end

  def html(games_container)
    games_container.inner_html
  end

  def xpath_for(element)
    result = "//div[@class='cap']" #element.xpath
    #    result = element.path
    @logger.debug "XPath for #{element}: #{result}"
    result
  end
end
