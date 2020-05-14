# frozen_string_literal: true

require 'faraday'
require 'dotenv'
require 'json'
require './services/ticker'

# top gainers and losers
class Top
  TYPE = {
    G: 'gainers',
    L: 'decliners'
  }.freeze

  Mover = Struct.new(
    :ticker,
    :name,
    :price,
    :percent,
    :performance,
    keyword_init: true
  )

  def initialize
    Dotenv.load
  end

  def gainers
    mover(TYPE[:G])
  end

  def losers
    mover(TYPE[:L])
  end

  def mover(type = TYPE[:G])
    request.dig('data', type, 'instruments').map do |s|
      Mover.new(
        ticker: s['ticker'],
        name: s['name'],
        price: s['lastPrice'],
        percent: s['percentChange']
        # performance: performance(s['ticker'])
      )
    end
  end

  def performance(ticker)
    Ticker.new(ticker).full_performance
  end

  def request
    req = Faraday.get(ENV['TOP_GAINERS_LOSERS_API'])

    JSON.parse(req.body)
  end
end
