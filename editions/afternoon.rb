# frozen_string_literal: true

require './editions/edition'
require './services/top'

module Editions
  class Afternoon < Edition
    def subject
      sample = indexes.to_a.sample(1).to_h
      key = sample.keys.first
      value = sample.values.first.performance

      index = Services::Ticker::ALIAS[key.to_sym]

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
      ].sample + ' today'
    end

    def subject_down(index, value)
      [
        "#{index} dropped #{value}",
        "#{index} closed down #{value}",
        "#{index} declined #{value}",
        "#{index} fell #{value}",
        "#{index} thumbled #{value}",
        "#{index} lost #{value}"
      ].sample + ' today'
    end

    def preheader
      trending = (top_gainers | top_losers).sample

      value = "#{trending.performance} to #{trending.price}"

      if trending.performance.start_with?(Templates::Element::MINUS)
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
        title: Services::Ticker::ALIAS[key],
        symbol: Services::Ticker::INDEX[key],
        value: indexes[key].performance,
        subtitle: indexes[key].price.to_s + ' pts'
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
        sp500: Services::Ticker.sp500,
        nasdaq: Services::Ticker.nasdaq,
        dowjones: Services::Ticker.dowjones
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
        title: stock.symbol + ' · ' + stock.price.to_s,
        subtitle: stock.name,
        symbol: stock.symbol,
        _1D: stock.stats['1D'],
        _5D: stock.stats['5D'],
        _1M: stock.stats['1M'],
        _3M: stock.stats['3M'],
        _6M: stock.stats['6M'],
        _1Y: stock.stats['1Y'],
        _5Y: stock.stats['5Y'],
        _10Y: stock.stats['10Y']
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
