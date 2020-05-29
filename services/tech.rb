# frozen_string_literal: true

require './services/ticker'

module Services
  class Tech
    LIST = {
      'Facebook': 'FB',
      'Apple': 'AAPL',
      'Amazon': 'AMZN',
      'Google': 'GOOG',
      'Microsoft': 'MSFT',
      'Netflix': 'NFLX',
      'Tesla': 'TSLA',
      'Advanced Micro Devices': 'AMD',
      'Intel Corporation': 'INTC'
    }.freeze

    def self.data
      LIST.map do |key, value|
        stock = Ticker.new(value)

        Ticker::Detail.new(
          ticker: value,
          name: key.to_s,
          price: stock.price,
          performance: stock.full_performance
        )
      end
    end
  end
end
