# frozen_string_literal: true

require './services/config'
require './services/ticker'
require 'faraday'
require 'json'

module Services
  class Trending
    def stocks
      key = %w[finance result]
      trending = request.dig(*key).first.dig('quotes')

      trending.take(6).map do |s|
        Ticker.new(s['symbol'])
      end
    end

    def request
      req = Faraday.get(Config::TRENDING_API)

      JSON.parse(req.body)
    end
  end
end
