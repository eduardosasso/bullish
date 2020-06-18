# frozen_string_literal: true

require './services/config'
require './services/ticker'
require 'faraday'
require 'json'

module Services
  class Trending
    LIMIT = 8
    def stocks(limit = LIMIT)
      key = %w[finance result]
      trending = request.dig(*key).first.dig('quotes')

      trending.take(limit).map do |s|
        Ticker.new(s['symbol'])
      end
    end

    def request
      req = Faraday.get(Config::TRENDING_API)

      JSON.parse(req.body)
    end
  end
end
