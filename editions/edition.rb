# frozen_string_literal: true

require './services/ticker'
require './templates/template'
require './services/holiday'
require './services/config'
require './services/trending'
require './services/crypto'
require './services/world'

# types of email
module Editions
  class Edition
    attr_writer :day_of_the_week

    MINUS = '-'

    DAY_ELEMENTS = {
      monday: :monday_elements,
      tuesday: :tuesday_elements,
      wednesday: :wednesday_elements,
      thursday: :thursday_elements,
      friday: :friday_elements
    }.freeze

    def subject
      raise 'should override subject'
    end

    def preheader
      raise 'should override preheader'
    end

    def content
      Templates::Template.new(elements, preheader).to_html
    end

    def elements
      raise 'override and return an Array of Element'
    end

    # override for editions like weekend
    def send?
      # TODO: rename to better name
      !Services::Holiday.today?
    end

    def monday_elements
      []
    end

    def tuesday_elements
      []
    end

    def wednesday_elements
      []
    end

    def thursday_elements
      []
    end

    def friday_elements
      []
    end

    def todays_elements(day = day_of_the_week)
      method = DAY_ELEMENTS[day.to_sym]
      send(method)
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
      gold = ticker(:gold)

      stats(gold)
    end

    def russell2000_performance
      russell2000 = ticker(:russell2000)
      stats(russell2000)
    end

    def treasury_performance
      treasury = ticker(:treasury)
      stats(treasury)
    end

    def generic_title(title, subtitle = nil, undertitle = nil)
      data = Templates::Element::Title.new(
        title: title,
        subtitle: subtitle,
        undertitle: undertitle
      )

      Templates::Element.title(data)
    end

    def index_performance
      [
        generic_title('Performance'),
        sp500_performance,
        nasdaq_performance,
        dowjones_performance,
        bitcoin_performance
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
        end,
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

    def ticker(key)
      Services::Ticker.send(key)
    end

    def day_of_the_week
      @day_of_the_week ||= Services::Config.date_time_et.strftime('%A').downcase
    end

    def formatted_date
      Services::Config.formatted_date
    end

    def formatted_time
      Services::Config.formatted_time
    end

    def subscribers_group_id
      raise 'override with subscribers group from mailerlite'
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

      title = Services::Ticker::ALIAS[ticker.key] || ticker.name
      symbol = Services::Ticker::INDEX[ticker.key] || ticker.symbol

      data = Templates::Element::Stats.new(
        title: title,
        subtitle: price,
        symbol: symbol,
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

    def stats_summary(ticker)
      data = Templates::Element::Group.new(
        title1: "Year to date",
        subtitle1: formatted_date,
        value1: ticker.stats['YTD'],
        title2: "All time high",
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

    def stats_top(stock)
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

    # save as html file for testing
    def save
      filename = 'tmp/' + subject + '.html'

      File.open(filename, 'w+') do |f|
        f.write(content)
      end
    end
  end
end
