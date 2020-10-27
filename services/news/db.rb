# frozen_string_literal: true

require './services/config'
require 'faraday'
require './services/log'
require 'active_support/all'

module Services
  module News
    class DB
      Item = Struct.new(
        :best,
        :symbol,
        :headline,
        :date,
        :source,
        :url,
        keyword_init: true
      )

      def self.save(items: [Item])
        # save in google sheets bulk update
        data = {
          data: items.collect(&:to_h)
        }

        Faraday.post(
          Services::Config::DB_API,
          data.to_json,
          'Content-Type' => 'application/json'
        )
      end

      def self.reset
        # reset DB to pristine state via schedule
        # every morning should start clean
        Faraday.delete("#{Services::Config::DB_API}/all")
      end

      def self.find(symbol)
        all.select do |news|
          news.symbol == symbol && news.best.present?
        end.sample
      rescue StandardError => e
        Services::Log.error("#{symbol} - #{e.message}")
      end

      # make sure we only call backend once
      # filter in memory to avoid api limit
      def self.all
        @all ||= begin
          req = Faraday.get(Services::Config::DB_API)
          JSON.parse(req.body, object_class: Item)
        end
      end
    end
  end
end
