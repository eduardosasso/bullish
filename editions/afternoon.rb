# frozen_string_literal: true

require './editions/edition'
require './services/top'
require './services/futures'
require './services/sector'

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
        main_title,
        Templates::Element.spacer('20px'),
        sp500_close,
        nasdaq_close,
        dowjones_close,
        Templates::Element.divider,
        todays_elements
      ]
    end

    def monday_elements
      [
        top_gainers_losers,
        world_futures
      ]
    end

    def tuesday_elements
      [world_futures]
    end

    def wednesday_elements
      [
        all_time_high,
        world_futures
      ]
    end

    def thursday_elements
      [world_futures]
    end

    def friday_elements
      sector_performance
    end

    def main_title
      generic_title(
        title = formatted_date,
        subtitle = 'Stock Market Closing Data',
        undertitle = formatted_time
      )
    end

    def sector_performance
      sector = Services::Sector.data.sample.map do |sector|
        stats(sector)
      end

      [
        generic_title('Sector', 'Performance')
      ] | sector
    end

    def top_gainers_losers
      [
        top_gainers_title,
        gainers_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        top_losers_tittle,
        losers_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider
      ]
    end

    def world_futures
      futures = Services::Futures.world.map do |key, value|
        name = Services::Futures::ALIAS[key]

        data = Templates::Element::Item.new(
          title: name[:title],
          subtitle: name[:subtitle],
          value: value
        )

        Templates::Element.item(data)
      end

      [
        generic_title('Tomorrow', 'Asia & Europe Futures'),
        Templates::Element.spacer('25px'),
        futures
      ]
    end

    def all_time_high
      data = Templates::Element::Group.new(
        title1: 'S&P 500',
        subtitle1: 'Feb 20, 2020',
        undertitle1: '3,190.14 pts',
        value1: '-6.7%',
        title2: 'Nasdaq',
        subtitle2: 'Jun 9, 2020',
        undertitle2: '10,020.34 pts',
        value2: '-0.3%'
      )

      group = Templates::Element.group(data)

      [
        generic_title('All-Time High', 'Difference since last record'),
        Templates::Element.spacer('25px'),
        # generic_item('S&P500', '-6.7%', 'Feb 20, 2020', '3190.14 pts'),
        # generic_item('Nasdaq', '-0.3%', 'Feb 22, 2020', '10020.347 pts'),
        # generic_item('Dow Jones', '-8.9%', 'Jan 18 2020', '26989.99 pts'),
        group,
        Templates::Element.divider
      ]
    end

    def generic_item(title, value, subtitle = nil, undertitle = nil)
      data = Templates::Element::Item.new(
        title: title,
        subtitle: subtitle,
        undertitle: undertitle,
        value: value
      )

      Templates::Element.item(data)
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

    def generic_title(title, subtitle = nil, undertitle = nil)
      data = Templates::Element::Title.new(
        title: title,
        subtitle: subtitle,
        undertitle: undertitle
      )

      Templates::Element.title(data)
    end

    def top_gainers_title
      generic_title('Top Gainers')
    end

    def top_losers_tittle
      generic_title('Top Losers')
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
      stats = stock.stats

      data = Templates::Element::Stats.new(
        title: stock.symbol + ' · ' + stock.price.to_s,
        subtitle: stock.name,
        symbol: stock.symbol,
        _1D: stats['1D'],
        _5D: stats['5D'],
        _1M: stats['1M'],
        _3M: stats['3M'],
        _6M: stats['6M'],
        _1Y: stats['1Y'],
        _5Y: stats['5Y'],
        _10Y: stats['10Y']
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
