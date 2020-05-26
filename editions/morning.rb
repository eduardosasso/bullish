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

      "#{ALIAS[key.to_sym]} is #{up_down} #{value} in premarket"
    end

    # TODO: add emoji
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
        Templates::Element.divider,
        performance_title,
        sp500_performance,
        nasdaq_performance,
        dowjones_performance,
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
      stats(:sp500)
    end

    def nasdaq_performance
      stats(:nasdaq)
    end

    def dowjones_performance
      stats(:dowjones)
    end

    def item(key)
      data = Templates::Element::Item.new(
        title: ALIAS[key],
        symbol: Services::Ticker::INDEX[key],
        value: futures[key]
      )

      Templates::Element.item(data)
    end

    def stats(key)
      stock = performance(key)

      data = Templates::Element::Stats.new(
        title: ALIAS[key],
        symbol: Services::Ticker::INDEX[key],
        _1D: stock['1D'],
        _5D: stock['5D'],
        _1M: stock['1M'],
        _3M: stock['3M'],
        _6M: stock['6M'],
        _1Y: stock['1Y'],
        _5Y: stock['5Y'],
        _10Y: stock['10Y']
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

    def performance_title
      data = Templates::Element::Title.new(
        title: 'Performance'
      )

      Templates::Element.title(data)
    end

    def subscribers_group_id
      ENV['FREE_GROUP']
    end

    def performance(key)
      Services::Ticker.send(key).full_performance
    end

    def futures
      @futures ||= Services::Futures.new.pre_market
    end
  end
end
