# frozen_string_literal: true

require './services/config'
require 'net/http'
require 'json'
require 'uri'

# fetch premarket futures % change
module Services
  class Futures
    USA = {
      sp500: 'Future-US-ES00',
      nasdaq: 'Future-US-NQ00',
      dowjones: 'Future-US-YM00'
    }.freeze

    WORLD = {
      nikkei: 'Future-US-NIY00',
      dax: 'Future-DE-DAX00',
      ftse: 'Future-UK-Z00'
    }.freeze

    def self.usa
      new.data(USA)
    end

    def self.world
      new.data(WORLD)
    end

    def data(list = USA)
      uri = URI(Services::Config::FUTURES_API)

      response = Net::HTTP.get(uri)

      {}.tap do |h|
        JSON.parse(response)['InstrumentResponses'].each do |r|
          key = list.key(r.dig('RequestId'))

          next unless key

          value = r.dig('Matches').first.dig('CompositeTrading', 'ChangePercent')

          h[key] = value.to_f.round(2).to_s + '%'
        end
      end
    end
  end
end
