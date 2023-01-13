# frozen_string_literal: true

require './services/ticker'

module Services
  class Crypto
    COINS = {
      'Bitcoin': 'BTC-USD',
      'Ethereum': 'ETH-USD'
    }.freeze

    def self.data
      COINS.map do |key, value|
        Ticker.new(value).tap do |t|
          t.name = key.to_s
        end
      end
    end
  end
end
