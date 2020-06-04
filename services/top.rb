# frozen_string_literal: true

require 'faraday'
require 'json'
require './services/config'
require './services/ticker'

# top gainers and losers
module Services
  class Top
    TYPE = {
      G: 'gainers',
      L: 'decliners'
    }.freeze

    def gainers
      mover(TYPE[:G])
    end

    def losers
      mover(TYPE[:L])
    end

    def mover(type = TYPE[:G])
      request.dig('data', type, 'instruments').map do |s|
        Ticker.new(s['ticker']).tap do |t|
          t.name =  s['name']
          t.price = '$' + s['lastPrice']
        end
      end
    end

    def request
      req = Faraday.get(Config::TOP_GAINERS_LOSERS_API)

      JSON.parse(req.body)
    end
  end
end
