# frozen_string_literal: true

require 'dotenv/load'
require 'active_support/all'

module Services
  class Config
    DATE_FORMAT = '%b %d, %Y'
    TIME_FORMAT = '%I:%M%p ET'
    TOP_GAINERS_LOSERS_API = ENV['TOP_GAINERS_LOSERS_API']
    FUTURES_API = ENV['MARKET_API']
    TRENDING_API =
      'https://query1.finance.yahoo.com/v1/finance/trending/US?count=50'
    QUOTE_SUMMARY_API =
      'https://query2.finance.yahoo.com/v10/finance/quoteSummary/%s?&modules=price,summaryDetail'
    ALL_TIME_HIGH_API =
      'https://query1.finance.yahoo.com/v8/finance/chart/%s?' \
        'period1=%s&period2=%s&interval=1d&includePrePost=false&indicators=quote'
    STATS_API = 'https://query1.finance.yahoo.com/v8/finance/chart/'
    DETAILS_API = 'https://query1.finance.yahoo.com/v7/finance/quote?symbols='
    REUTERS_NEWS =
      'https://mobile.reuters.com/assets/jsonHeadlines?channel=75&limit=1'
    STOCK_NEWS = ENV['STOCK_NEWS']
    IEX_TOKEN = ENV['IEX_TOKEN']
    DB_API = ENV['DB_API']
    TWITTER_DB_API = ENV['TWITTER_DB_API']
    TWITTER_QUERY = ENV['TWITTER_QUERY']

    # get historical performance by ticker symbol
    # https://query1.finance.yahoo.com/v8/finance/chart/^IXIC?interval=1d&range=1d
    # https://query2.finance.yahoo.com/v10/finance/quoteSummary/AAPL?&modules=defaultKeyStatistics,financialData,calendarEvents
    # https://query2.finance.yahoo.com/v10/finance/quoteSummary/BTC-USD?&modules=price%2CsummaryDetail
    # https://feeds.finance.yahoo.com/rss/2.0/headline?s=^GSPC&region=US&lang=en-US

    # date time in ET where markets operate
    def self.date_time_et
      DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)')
    end

    def self.formatted_date
      Services::Config.date_time_et.strftime(DATE_FORMAT)
    end

    def self.formatted_time
      Services::Config.date_time_et.strftime(TIME_FORMAT)
    end

    def self.test?
      !ENV['TEST_GROUP'].nil?
    end

    def self.premium_group
      [ENV['PREMIUM_GROUP'], ENV['PREMIUM_GROUP_TRIAL']].compact
    end

    def self.free_group
      ENV['FREE_GROUP']
    end

    def self.test_group
      [ENV['TEST_GROUP'], ENV['TEST_GROUP_TRIAL']].compact
    end
  end
end
