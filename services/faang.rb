require './services/ticker'

class FAANG
  LIST = {
    'Facebook': 'FB',
    'Apple': 'AAPL',
    'Amazon': 'AMZN',
    'Netflix': 'NFLX',
    'Google': 'GOOG'
  }

  def self.data
    LIST.map do |key, value|
      Ticker::Detail.new(
        ticker: value,
        name: key,
        price: 0,
        performance: Ticker.new(value).full_performance
      )
    end
  end
end
