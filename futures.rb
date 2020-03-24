# frozen_string_literal: true

require 'dotenv'
require 'net/http'
require 'json'

#fetch pre-market futures % change
class Futures
  INDEX = {
    sp500: 'Future-US-ES00',
    nasdaq: 'Future-US-NQ00',
    dowjones: 'Future-US-YM00'
  }.freeze

  def initialize
    Dotenv.load
  end

  def uri
    URI(ENV['MARKET_API'])
  end

  def self.pre_market
    new.pre_market
  end

  def pre_market
    response = Net::HTTP.get(uri)

    {}.tap do |h|
      JSON.parse(response)['InstrumentResponses'].each do |r|
        key = INDEX.key(r.dig('RequestId'))

        next unless key

        value = r.dig('Matches').first.dig('CompositeTrading', 'ChangePercent')

        h[key] = value.to_f.round(2).to_s
      end
    end
  end
end
