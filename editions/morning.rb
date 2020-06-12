# frozen_string_literal: true

require './editions/edition'
require './services/futures'
require './templates/template'
require './templates/element'

module Editions
  class Morning < Edition
    def subject
      sample = futures.to_a.sample(1).to_h
      key = sample.keys.first
      value = sample.values.first

      up_down = value.start_with?(Templates::Element::MINUS) ? 'down' : 'up'

      "#{Services::Ticker::ALIAS[key.to_sym]} is #{up_down} #{value} in premarket"
    end

    # TODO: add emoji
    # TODO add some random stock number here
    def preheader
      [
        'Do not put all your eggs in one basket',
        'Our favorite holding period is forever',
        '1: Never lose money. 2: Never forget 1'
      ].sample
    end

    def elements
      [
        title,
        Templates::Element.spacer('20px'),
        sp500_futures,
        nasdaq_futures,
        dowjones_futures,
        todays_elements,
        Templates::Element.spacer('20px')
      ]
    end

    def sp500_futures
      item(:sp500)
    end

    def nasdaq_futures
      item(:nasdaq)
    end

    def dowjones_futures
      item(:dowjones)
    end

    def sp500_performance
      sp500 = ticker(:sp500)
      price = sp500.price.to_s + ' pts'

      stats(sp500, price)
    end

    def nasdaq_performance
      nasdaq = ticker(:nasdaq)
      price = nasdaq.price.to_s + ' pts'

      stats(nasdaq, price)
    end

    def dowjones_performance
      dowjones = ticker(:dowjones)
      price = dowjones.price.to_s + ' pts'

      stats(dowjones, price)
    end

    def bitcoin_performance
      bitcoin = ticker(:bitcoin)
      price = '$' + bitcoin.price.to_s

      stats(bitcoin, price)
    end

    def gold_performance
      stats(:gold)
    end

    def russell2000_performance
      stats(:russell2000)
    end

    def treasury_performance
      stats(:treasury)
    end

    # def monday_elements
    def thursday_elements
      [
        Templates::Element.divider,
        generic_title('Performance'),
        sp500_performance,
        nasdaq_performance,
        dowjones_performance,
        bitcoin_performance
      ]
    end

    def tuesday_elements
      [
        Templates::Element.divider,
        generic_title('Trending')

      ]
    end

    def item(key)
      data = Templates::Element::Item.new(
        title: Services::Ticker::ALIAS[key],
        symbol: Services::Ticker::INDEX[key],
        value: futures[key]
      )

      Templates::Element.item(data)
    end

    def stats(ticker, price = nil)
      performance = ticker.stats
      price ||= ticker.price

      data = Templates::Element::Stats.new(
        title: Services::Ticker::ALIAS[ticker.key],
        subtitle: price,
        symbol: Services::Ticker::INDEX[ticker.key],
        _1D: performance['1D'],
        _5D: performance['5D'],
        _1M: performance['1M'],
        _3M: performance['3M'],
        _6M: performance['6M'],
        _1Y: performance['1Y'],
        _5Y: performance['5Y'],
        _10Y: performance['10Y']
      )

      Templates::Element.stats(data)
    end

    def title
      data = Templates::Element::Title.new(
        title: formatted_date,
        subtitle: 'Stock Futures Premarket Data',
        undertitle: formatted_time
      )

      Templates::Element.title(data)
    end

    def generic_title(title = 'Performance')
      data = Templates::Element::Title.new(
        title: title
      )

      Templates::Element.title(data)
    end

    def subscribers_group_id
      ENV['PREMIUM_GROUP']
    end

    def ticker(key)
      Services::Ticker.send(key)
    end

    def futures
      @futures ||= Services::Futures.usa
    end
  end
end
