require './services/ticker'

class World
  LIST = {
    'Japan Nikkei 225': 'BTC-USD',
    'London FTSE 100': 'ETH-USD',
    'German DAX': 'XRP-USD',
    'France CAC 40',
    'Europe STOXX 600',
    'Hong Kong Hang Seng',
    'Shanghai'
    'India BSE SENSEX',
    'Australia S&P/ASX 200'
  }

  # china, japan, uk, germany, europe, russia, brazil, india 

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
