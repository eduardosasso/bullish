# frozen_string_literal: true

require './services/config'
require './services/news/db'
require './services/log'
require 'faraday'

module Services
  module News
    class Crawler
      def self.stock(symbol)
        api = format(
          Services::Config::STOCK_NEWS,
          CGI.escape(symbol),
          Services::Config::IEX_TOKEN
        )

        req = Faraday.get(URI(api))

        JSON.parse(req.body).map do |item|
          sec = (item['datetime'].to_f / 1000).to_s
          date = Date.strptime(sec, '%s')

          News::DB::Item.new(
            best: false,
            symbol: symbol,
            headline: item['headline'],
            date: date,
            source: item['source'],
            url: item['url']
          )
        end
      rescue StandardError => e
        unknown_symbol = e.message.match?('Unknown symbol')
        Services::Log.error("#{symbol} - #{e.message}") unless unknown_symbol
        nil
      end
    end
  end
end
