# frozen_string_literal: true

require 'faraday'
require 'active_support/all'
require './services/percent'
require './services/peak'
require './services/config'
require './services/news/db'

module Services
  class Ticker
    attr_writer :request, :name, :price
    attr_reader :symbol, :key

    ALIAS = {
      'sp500': 'S&P 500',
      'nasdaq': 'Nasdaq',
      'dowjones': 'Dow Jones',
      'bitcoin': 'Bitcoin',
      'gold': 'Gold',
      'treasury': '10-Yr Treasury',
      'russell2000': 'Russell 2000'
    }.freeze

    SUB_ALIAS = {
      'treasury': '10-Yr Bond'
    }.freeze

    INDEX = {
      sp500: '^GSPC',
      nasdaq: '^IXIC',
      dowjones: '^DJI',
      bitcoin: 'BTC-USD',
      gold: 'GC=F',
      treasury: '^TNX',
      russell2000: '^RUT'
    }.freeze

    RANGE =
      {
        '1D': '1d',
        '5D': '5d',
        '1M': '1mo',
        '3M': '3mo',
        '6M': '6mo',
        '1Y': '1y',
        '5Y': '5y',
        '10Y': '10y',
        'YTD': 'ytd',
        'MAX': 'max'
      }.with_indifferent_access

    RANGE_DATE =
      {
        '1d': 1.day.ago,
        '5d': 5.days.ago,
        '1mo': 1.month.ago,
        '3mo': 3.months.ago,
        '6mo': 6.months.ago,
        '1y': 1.year.ago,
        '5y': 5.years.ago,
        '10y': 10.years.ago
      }.with_indifferent_access

    def initialize(symbol, range = RANGE['1D'])
      @symbol = symbol
      @key = INDEX.key(symbol)
      @range = range
    end

    def self.sp500(range = RANGE['1D'])
      new(INDEX[:sp500], range)
    end

    def self.nasdaq(range = RANGE['1D'])
      new(INDEX[:nasdaq], range)
    end

    def self.dowjones(range = RANGE['1D'])
      new(INDEX[:dowjones], range)
    end

    def self.bitcoin(range = RANGE['1D'])
      new(INDEX[:bitcoin], range)
    end

    def self.gold(range = RANGE['1D'])
      new(INDEX[:gold], range)
    end

    def self.treasury(range = RANGE['1D'])
      new(INDEX[:treasury], range)
    end

    def self.russell2000(range = RANGE['1D'])
      new(INDEX[:russell2000], range)
    end

    def stats
      {}.tap do |stats|
        RANGE.each do |key, value|
          stats[key] = Ticker.new(@symbol, value).performance
        end
      end
    end

    def name
      @name ||= ALIAS[@key] || details.dig('displayName') || details.dig('shortName')
    end

    def price
      @price ||= format_number(data.dig('meta', 'regularMarketPrice'))
    end

    def performance
      quotes.unshift(prev_close) if @range == RANGE['1D']

      return '—' unless in_date_range?

      Percent.diff(quotes.last, quotes.first).to_s
    end

    def format_number(number)
      ActiveSupport::NumberHelper.number_to_rounded(number, delimiter: ',', precision: 2)
    end

    def peak
      @peak ||= Peak.new(@symbol)
    end

    def news
      Services::News::DB.find(@symbol)
    end

    def url
      params = [
        'interval=1d',
        'range=' + @range
      ].join('&')

      symbol = ERB::Util.url_encode(@symbol)

      Config::STATS_API + symbol + '?' + params
    end

    # TODO: improve log
    def request(endpoint = url, debug = false)
      Faraday.get(endpoint).tap do |r|
        log(r) if debug
      end.body
    end

    def prev_close
      data.dig('meta', 'chartPreviousClose')
    end

    def quotes
      data.dig('indicators', 'quote').first.dig('close')
    end

    def timestamp
      data.dig('timestamp').first
    end

    def date
      Time.at(timestamp).to_datetime
    end

    def in_date_range?
      range_date = RANGE_DATE[@range]

      return true if range_date.nil?

      # 2 day buffer
      # check if timestamp matches range req
      (range_date.to_datetime - date)
        .to_i
        .between?(-2, 2)
    end

    def log(request)
      key = INDEX.key(@symbol)
      filename = "tmp/#{key}_#{@range}.json"

      result = JSON.parse(request.body)
      result[:url] = url

      File.open(filename, 'w+') do |f|
        f.write(JSON.pretty_generate(result))
      end
    end

    def details
      @details ||=
        begin
          result = request(
            Config::DETAILS_API + @symbol,
            false
          )

          JSON.parse(result)
              .dig('quoteResponse', 'result')
              .try(:first)
        end
    end

    def data
      @data ||=
        begin
          data = JSON.parse(request)

          raise data if data.dig('chart', 'error')

          data.dig('chart', 'result').first
        end
    end
  end
end
