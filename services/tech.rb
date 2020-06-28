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
        Ticker.new(value).tap do |t|
          t.name = key.to_s
        end
      end
    end
  end
end
