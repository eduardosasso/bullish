# frozen_string_literal: true

require './services/ticker'

module Services
  class Crypto
    COINS = {
      'Bitcoin': 'BTC-USD',
      'Ethereum': 'ETH-USD',
      'XRP-Ripple': 'XRP-USD'
    }.freeze

    def self.data
      COINS.map do |key, value|
        Ticker::Detail.new(
          ticker: value,
          name: key,
          price: 0,
          performance: Ticker.new(value).full_performance
        )
      end
    end
  end
end
