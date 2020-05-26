# frozen_string_literal: true

require './editions/edition'
require './services/top'

module Editions
  class Afternoon < Edition
    def subject
      sample = indexes.to_a.sample(1).to_h
      key = sample.keys.first
      value = sample.values.first

      index = ALIAS[key.to_sym]

      if value.start_with?(Templates::Element::MINUS)
        subject_down(index, value)
      else
        subject_up(index, value)
      end
    end

    def subject_up(index, value)
      [
        "#{index} closed up #{value}",
        "#{index} jumped #{value}",
        "#{index} rose #{value}",
        "#{index} added #{value}",
        "#{index} climbed #{value}",
        "#{index} finished up #{value}"
      ].sample
    end

    def subject_down(index, value)
      [
        "#{index} dropped #{value}",
        "#{index} closed down #{value}",
        "#{index} declined #{value}",
        "#{index} fell #{value}",
        "#{index} thumbled #{value}",
        "#{index} lost #{value}"
      ].sample
    end

    def preheader
      trending = (top_gainers | top_losers).sample

      value = "#{trending.percent} to #{trending.price}"

      if trending.percent.start_with?(Templates::Element::MINUS)
        subject_down(trending.name, value)
      else
        subject_up(trending.name, value)
      end
    end

    def elements
      [
        title,
        Templates::Element.spacer('20px'),
        sp500_close,
        nasdaq_close,
        dowjones_close,
        Templates::Element.divider,
        top_gainers_title,
        gainers_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        top_losers_tittle,
        losers_performance,
        Templates::Element.spacer('20px')
      ]
    end

    def title
      data = Templates::Element::Title.new(
        title: formatted_date,
        subtitle: 'Stock Market Closing Data',
        undertitle: formatted_time
      )

      Templates::Element.title(data)
    end

    def sp500_close
      item(:sp500)
    end

    def nasdaq_close
      item(:nasdaq)
    end

    def dowjones_close
      item(:dowjones)
    end

    def item(key)
      data = Templates::Element::Item.new(
        title: ALIAS[key],
        symbol: Services::Ticker::INDEX[key],
        value: indexes[key]
      )

      Templates::Element.item(data)
    end

    def top_gainers_title
      data = Templates::Element::Title.new(
        title: 'Top Gainers'
      )

      Templates::Element.title(data)
    end

    def top_losers_tittle
      data = Templates::Element::Title.new(
        title: 'Top Losers'
      )

      Templates::Element.title(data)
    end

    def indexes
      @indexes ||= {
        sp500: Services::Ticker.sp500.performance,
        nasdaq: Services::Ticker.nasdaq.performance,
        dowjones: Services::Ticker.dowjones.performance
      }
    end

    def gainers_performance
      top_gainers.map do |stock|
        stats(stock)
      end
    end

    def losers_performance
      top_losers.map do |stock|
        stats(stock)
      end
    end

    def stats(stock)
      data = Templates::Element::Stats.new(
        title: stock.ticker + ' · ' + stock.price,
        subtitle: stock.name,
        symbol: stock.ticker,
        _1D: stock.performance['1D'],
        _5D: stock.performance['5D'],
        _1M: stock.performance['1M'],
        _3M: stock.performance['3M'],
        _6M: stock.performance['6M'],
        _1Y: stock.performance['1Y'],
        _5Y: stock.performance['5Y'],
        _10Y: stock.performance['10Y']
      )

      Templates::Element.stats(data)
    end

    def top_gainers
      @top_gainers ||= Services::Top.new.gainers
    end

    def top_losers
      @top_losers ||= Services::Top.new.losers
    end

    def subscribers_group_id
      ENV['PREMIUM_GROUP']
    end
  end
end
