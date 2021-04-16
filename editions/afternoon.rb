# frozen_string_literal: true

require './editions/edition'
require './services/top'
require './services/futures'
require './services/sector'

module Editions
  class Afternoon < Edition
    def subject
      @subject ||= begin
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
    end

    def subject_up(index, value)
      [
        "#{index} closed up #{value}",
        "#{index} jumped #{value}",
        "#{index} rose #{value}",
        "#{index} added #{value}",
        "#{index} climbed #{value}",
        "#{index} finished up #{value}"
      ].sample + ' ' + ['today', day_of_the_week.to_s].sample
    end

    def subject_down(index, value)
      [
        "#{index} dropped #{value}",
        "#{index} closed down #{value}",
        "#{index} declined #{value}",
        "#{index} fell #{value}",
        "#{index} thumbled #{value}",
        "#{index} lost #{value}"
      ].sample + ' ' + ['today', day_of_the_week.to_s].sample
    end

    def preheader
      trending = (top_gainers | top_losers).sample

      value = "#{trending.performance} to #{trending.price}"

      trending.performance.start_with?(Templates::Element::MINUS) ? "🔴" : "🟢"
    end

    def name
      'Afternoon edition'
    end

    def elements
      [
        generic_title('Closing', formatted_time),

        Templates::Element.spacer('20px'),
        item_close(:sp500),
        item_close(:nasdaq),
        item_close(:dowjones),
        item_close(:bitcoin),
        Templates::Element.divider,
        todays_elements
      ]
    end

    def monday_elements
      [
        top_gainers_losers_performance
      ]
    end

    def tuesday_elements
      [
        monday_elements
      ]
    end

    def wednesday_elements
      [
        monday_elements
      ]
    end

    def thursday_elements
      [
        monday_elements
      ]
    end

    def friday_elements
      [
        index_week_summary,
        Templates::Element.divider,
        top_gainers_losers,
        sector_summary
      ]
    end

    def item_close(key)
      data = Templates::Element::Item.new(
        title: Services::Ticker::ALIAS[key],
        symbol: Services::Ticker::INDEX[key],
        value: indexes[key].performance,
        subtitle: indexes[key].price
      )

      Templates::Element.item(data)
    end

    def indexes
      @indexes ||= {
        sp500: Services::Ticker.sp500,
        nasdaq: Services::Ticker.nasdaq,
        dowjones: Services::Ticker.dowjones,
        bitcoin: Services::Ticker.bitcoin
      }
    end

    def subscribers_group_id
      Services::Config.premium_group
    end
  end
end
