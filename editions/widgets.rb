# frozen_string_literal: true

module Editions
  module Widgets
    def index_performance
      [
        generic_title('Performance'),
        sp500_performance,
        nasdaq_performance,
        dowjones_performance
      ]
    end

    def index_summary
      [
        generic_title('S&P 500'),
        Templates::Element.spacer('15px'),
        stats_summary(ticker(:sp500)),
        generic_title('Nasdaq'),
        Templates::Element.spacer('15px'),
        stats_summary(ticker(:nasdaq)),
        generic_title('Dow Jones'),
        Templates::Element.spacer('15px'),
        stats_summary(ticker(:dowjones)),
        generic_title('Bitcoin'),
        Templates::Element.spacer('15px'),
        stats_summary(ticker(:bitcoin))
      ]
    end

    def index_week_summary
      [
        generic_title('Week', 'Summary'),
        Templates::Element.spacer('25px'),
        stats_week_summary(ticker(:sp500)),
        stats_week_summary(ticker(:nasdaq)),
        stats_week_summary(ticker(:dowjones)),
        stats_week_summary(ticker(:bitcoin))
      ]
    end

    def sector_summary
      [
        generic_title('Sector', 'Performance'),
        Templates::Element.spacer('25px'),
        Services::Sector.data.sample(6).map do |sector|
          [
            generic_title(sector.name),
            Templates::Element.spacer('15px'),
            stats_summary(sector)
          ]
        end
      ]
    end

    def trending(limit = Services::Trending::LIMIT)
      [
        generic_title('Trending'),
        Services::Trending.new.stocks(limit).map do |ticker|
          stats_top(ticker)
        end,
        Templates::Element.spacer('20px')
      ]
    end

    def crypto
      [
        generic_title('Crypto'),
        Templates::Element.spacer('25px'),
        Services::Crypto.data.map do |ticker|
          [
            generic_title(ticker.name, ticker.price),
            Templates::Element.spacer('15px'),
            stats_summary(ticker)
          ]
        end
      ]
    end

    def world
      [
        generic_title('International'),
        Templates::Element.spacer('35px'),
        Services::World.data.sample(4).map do |ticker|
          [
            generic_title(ticker.name),
            Templates::Element.spacer('15px'),
            stats_summary(ticker)
          ]
        end
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

    def top_gainers_losers_performance
      [
        top_gainers_title,
        top_gainers_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        top_losers_tittle,
        top_losers_performance,
        Templates::Element.spacer('20px')
      ]
    end

    def top_gainers_losers
      [
        top_gainers_title,
        Templates::Element.spacer('25px'),
        top_gainers_items,
        Templates::Element.divider,
        top_losers_tittle,
        Templates::Element.spacer('25px'),
        top_losers_items,
        Templates::Element.divider
      ]
    end

    def top_gainers_items
      top_gainers.map do |stock|
        title = stock.symbol + ' · ' + stock.price.to_s
        subtitle = stock.name

        generic_item(title, stock.stats['1D'], subtitle)
      end
    end

    def top_losers_items
      top_losers.map do |stock|
        title = stock.symbol + ' · ' + stock.price.to_s
        subtitle = stock.name

        generic_item(title, stock.stats['1D'], subtitle)
      end
    end

    def top_gainers_performance
      top_gainers.map do |stock|
        stats_top(stock)
      end
    end

    def top_losers_performance
      top_losers.map do |stock|
        stats_top(stock)
      rescue StandardError => e
        Service::Log.error(e.message)

        nil
      end.compact
    end

    def top_gainers
      @top_gainers ||= Services::Top.new.gainers
    end

    def top_losers
      @top_losers ||= Services::Top.new.losers
    end

    def futures
      @futures ||= Services::Futures.usa
    end

    def generic_title(title, subtitle = nil, undertitle = nil)
      data = Templates::Element::Title.new(
        title: title,
        subtitle: subtitle,
        undertitle: undertitle
      )

      Templates::Element.title(data)
    end

    def main_title(subtitle)
      generic_title(
        formatted_date,
        subtitle,
        formatted_time
      )
    end

    def top_gainers_title
      generic_title('Top Gainers')
    end

    def top_losers_tittle
      generic_title('Top Losers')
    end

    def item_futures(key)
      data = Templates::Element::Item.new(
        title: Services::Ticker::ALIAS[key],
        symbol: Services::Ticker::INDEX[key],
        value: futures[key]
      )

      Templates::Element.item(data)
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

    def stats(ticker, title = nil, subtitle = nil)
      performance = ticker.stats

      title ||= Services::Ticker::ALIAS[ticker.key] || ticker.name
      subtitle ||= ticker.price

      symbol = Services::Ticker::INDEX[ticker.key] || ticker.symbol

      news = ticker.news || {}

      data = Templates::Element::Stats.new(
        title: title,
        subtitle: subtitle,
        symbol: symbol,
        news: news[:headline],
        news_url: news[:url],
        news_source: news[:source],
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

    def stats_top(stock)
      title = stock.symbol + ' · ' + stock.price.to_s
      subtitle = stock.name

      stats(stock, title, subtitle)
    end

    def stats_summary(ticker)
      data = Templates::Element::Group.new(
        title1: 'Year to date',
        subtitle1: formatted_date,
        value1: ticker.stats['YTD'],
        title2: 'All time high',
        subtitle2: ticker.peak.date,
        value2: ticker.peak.diff
      )

      Templates::Element.group(data)
    end

    def stats_week_summary(ticker)
      data = Templates::Element::Item.new(
        title: ticker.name,
        subtitle: ticker.price,
        symbol: ticker.symbol,
        value: ticker.stats['5D']
      )

      Templates::Element.item(data)
    end
  end
end
