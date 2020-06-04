# frozen_string_literal: true

require './services/ticker'

# https://www.etftrends.com/equity-etf-channel/the-11-stock-market-sectors-and-biggest-related-etfs/
module Services
  class Sector
    LIST = {
      'Energy': 'XLE',
      'Materials': 'GDX',
      'Industrials': 'DIA',
      'Consumer Discretionary': 'XLY',
      'Consumer Staples': 'XLP',
      'Health Care': 'XLV',
      'Financials': 'XLF',
      'Technology': 'XLK',
      'Telecommunication': 'XLC',
      'Utilities': 'XLU',
      'Real Estate': 'VNQ'
    }.freeze

    def self.data
      LIST.map do |key, value|
        Ticker.new(value).tap do |t|
          t.name = key.to_s
        end
      end
    end
  end
end
