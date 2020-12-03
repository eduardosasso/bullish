# frozen_string_literal: true

require './services/config'
require 'faraday'
require './services/log'
require './templates/element'

module Services
  class Twitter
    attr_reader :tweets

    Item =
      Struct.new(
        :ticker,
        :variant1,
        :variant2,
        :variant3,
        :url,
        :date,
        keyword_init: true
      )
    def initialize
      @tweets = []
    end

    def add_tweet(stock)
      today = Date.today.strftime('%Y-%m-%d')

      query = format(Services::Config::TWITTER_QUERY, stock.symbol, today)
      url = 'https://twitter.com/search?q=' + CGI.escape(query)

      @tweets <<
        Item.new(
          ticker: stock.symbol,
          variant1: variant1(stock),
          variant2: nil,
          # all time high?
          variant3: nil,
          url: url,
          date: today
        )
    end

    def variant1(stock)
      variant = ''

      stock.stats.each do |key, value|
        next if value == '—'
        next if key == 'MAX'

        icon = value.start_with?(Templates::Element::MINUS) ? '▽' : '△'

        variant += "#{key} #{icon} #{value}\n"
      end

      variant
    end

    def save_tweets
      data = { data: tweets }

      Faraday.post(
        Services::Config::TWITTER_DB_API,
        data.to_json,
        'Content-Type' => 'application/json'
      )
    end

    def self.reset_tweets
      Faraday.delete("#{Services::Config::TWITTER_DB_API}/all")
    end
  end
end
