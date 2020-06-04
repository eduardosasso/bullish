# frozen_string_literal: true

require './services/ticker'

module Services
  class World
    LIST = {
      'Japan Nikkei 225': '^N225',
      'UK FTSE 100': '^FTSE',
      'German DAX': '^GDAXI',
      'France CAC 40': '^FCHI',
      'Europe STOXX 600': '^STOXX',
      'Hong Kong Hang Seng': '^HSI',
      'China Composite': '^SSEC',
      'India BSE SENSEX': '^BSESN',
      'Australia S&P/ASX 200': '^AXJO',
      'Brazil Ibovespa': '^BVSP'
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
