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
        coin = Ticker.new(value)

        Ticker::Detail.new(
          ticker: value,
          name: key.to_s,
          price: coin.price,
          performance: coin.full_performance
        )
      end
    end
  end
end
