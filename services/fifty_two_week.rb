# frozen_string_literal: true

require './services/config'
require './services/percent'
require 'json'
require 'uri'

module Services
  class FiftyTwoWeek
    def initialize(symbol)
      @symbol = symbol
    end

    def down_from_high
      return unless current_value < high_value

      Percent.diff(current_value, high_value).to_s
    end

    def up_from_low
      return unless current_value > low_value

      Percent.diff(current_value, low_value).to_s
    end

    def current_value
      request.dig('price', 'regularMarketPrice', 'raw')
    end

    def high_value
      request.dig('summaryDetail', 'fiftyTwoWeekHigh', 'raw')
    end

    def low_value
      request.dig('summaryDetail', 'fiftyTwoWeekLow', 'raw')
    end

    def request
      @request ||=
        begin
          api = URI.escape(Config::QUOTE_SUMMARY_API % @symbol)

          req = Faraday.get(URI(api))

          JSON.parse(req.body)
              .dig('quoteSummary', 'result')
              .first
        end
    end
  end
end
