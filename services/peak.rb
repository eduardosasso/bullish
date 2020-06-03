require 'date'
require 'uri'
require './services/config'
require './services/percent'
require 'faraday'
require 'json'

module Services
  class Peak
    BEGIN_DATE = Date.parse('1900-01-01').to_time.to_i
    END_DATE = Config.date_time_et.to_i

    def initialize(symbol)
      @symbol = symbol
    end

    def max_value
      quotes.map(&:to_f).max
    end

    def current_value
      quotes.last
    end

    def diff
      Percent.diff(current_value, max_value).to_s
    end

    def date
      index = quotes.index(max_value)

      Time.at(timestamp[index])
    end

    def quotes
      request
        .dig('indicators', 'adjclose')
        .first.dig('adjclose')
    end

    def timestamp
      request.dig('timestamp')
    end

    def request
      @request ||=
        begin
          api = URI.escape(Config::ALL_TIME_HIGH_API % [@symbol, BEGIN_DATE, END_DATE])

          req = Faraday.get(URI(api))

          JSON.parse(req.body)
            .dig('chart', 'result')
            .first
        end
    end
  end
end
