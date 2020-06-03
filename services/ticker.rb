# frozen_string_literal: true

require 'faraday'
require 'active_support/all'
require './services/percent'
require './services/peak'
require './services/config'

module Services
  class Ticker
    attr_writer :request, :name
    attr_reader :symbol

    ALIAS = {
      'sp500': 'S&P 500',
      'nasdaq': 'Nasdaq',
      'dowjones': 'Dow Jones',
      'bitcoin': 'Bitcoin',
      'gold': 'Gold',
      'treasury': 'Treasury',
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

    def initialize(symbol, range = RANGE['1D'])
      @symbol = symbol
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
      @name ||= details.dig('displayName')
    end

    def price
      data.dig('meta', 'regularMarketPrice')
    end

    def performance
      quotes.unshift(prev_close) if @range == RANGE['1D']

      Percent.diff(quotes.last, quotes.first).to_s
    end

    def peak
      Peak.new(@symbol)
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
    def request(endpoint = url, debug = true)
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
            endpoint = Config::DETAILS_API + @symbol,
            debug = false
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
