# frozen_string_literal: true

require 'faraday'
require 'active_support/all'

# get historical performance by ticker symbol
module Services
  class Ticker
    attr_writer :request

    Detail = Struct.new(
      :ticker,
      :name,
      :price,
      :percent,
      :volume,
      :performance,
      keyword_init: true
    )

    INDEX = {
      sp500: '^GSPC',
      nasdaq: '^IXIC',
      dowjones: '^DJI'
    }.freeze

    ENDPOINT = 'https://query1.finance.yahoo.com/v8/finance/chart/'
    KEY = %w[chart result].freeze

    RANGE =
      {
        '1D': '1d',
        '5D': '5d',
        '1M': '1mo',
        '3M': '3mo',
        '6M': '6mo',
        '1Y': '1y',
        '5Y': '5y',
        '10Y': '10y'
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

    def full_performance
      {}.tap do |stats|
        RANGE.each do |key, value|
          stats[key] = Ticker.new(@symbol, value).performance
        end
      end
    end

    def price
      # https://query2.finance.yahoo.com/v10/finance/quoteSummary/AAPL?&modules=defaultKeyStatistics,financialData,calendarEvents
      # https://query2.finance.yahoo.com/v10/finance/quoteSummary/BTC-USD?&modules=price%2CsummaryDetail
    end

    def performance
      quotes.unshift(prev_close) if @range == RANGE['1D']

      percent_change(quotes.last, quotes.first).to_s + '%'
    end

    def percent_change(new, original)
      (((new.to_f - original.to_f) / original.to_f) * 100).round(2)
    end

    def url
      params = [
        'interval=1d',
        'range=' + @range
      ].join('&')

      symbol = ERB::Util.url_encode(@symbol)

      ENDPOINT + symbol + '?' + params
    end

    def request
      Faraday.get(url).tap do |r|
        log(r)
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

    def data
      @data ||= begin
                  data = JSON.parse(request)

                  raise data if data.dig('chart', 'error')

                  data.dig(*KEY).first
                end
    end
  end
end
