# frozen_string_literal: true

require './editions/edition'
require './services/futures'

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
        Templates::Element.divider,
        todays_elements
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

    def monday_elements
      [
        index_summary,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        trending(5)
      ]
    end

    def tuesday_elements
      [
        index_performance,
        gold_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        trending(3)
      ]
    end

    def wednesday_elements
      [
        index_performance,
        treasury_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        trending(3)
      ]
    end

    def thursday_elements
      [
        index_performance,
        russell2000_performance,
        Templates::Element.spacer('20px'),
        Templates::Element.divider,
        trending(3)
      ]
    end

    def friday_elements
      [
        trending(3),
        Templates::Element.divider,
        crypto,
        Templates::Element.divider,
        world
      ]
    end

    def title
      data = Templates::Element::Title.new(
        title: formatted_date,
        subtitle: 'Stock Futures Premarket Data',
        undertitle: formatted_time
      )

      Templates::Element.title(data)
    end

    def subscribers_group_id
      ENV['PREMIUM_GROUP']
    end

    def futures
      @futures ||= Services::Futures.usa
    end
  end
end
