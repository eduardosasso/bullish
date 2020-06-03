# frozen_string_literal: true

require 'dotenv/load'
require 'active_support/all'

module Services
  class Config
    TOP_GAINERS_LOSERS_API = ENV['TOP_GAINERS_LOSERS_API']
    FUTURES_API_URI = ENV['MARKET_API']
    TRENDING_API = ENV['TRENDING_API']
    QUOTE_SUMMARY_API = 'https://query2.finance.yahoo.com/v10/finance/quoteSummary/%s?&modules=price,summaryDetail'
    ALL_TIME_HIGH_API = 'https://query1.finance.yahoo.com/v8/finance/chart/%s?period1=%s&period2=%s&interval=1d&includePrePost=false&indicators=quote'
    STATS_API = 'https://query1.finance.yahoo.com/v8/finance/chart/'
    DETAILS_API = 'https://query1.finance.yahoo.com/v7/finance/quote?symbols='

    # get historical performance by ticker symbol
    # https://query1.finance.yahoo.com/v8/finance/chart/^IXIC?interval=1d&range=1d
    # https://query2.finance.yahoo.com/v10/finance/quoteSummary/AAPL?&modules=defaultKeyStatistics,financialData,calendarEvents
    # https://query2.finance.yahoo.com/v10/finance/quoteSummary/BTC-USD?&modules=price%2CsummaryDetail
    # https://feeds.finance.yahoo.com/rss/2.0/headline?s=^GSPC&region=US&lang=en-US

    # date time in ET where markets operate
    def self.date_time_et
      DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)')
    end
  end
end
