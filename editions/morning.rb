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

    def preheader
      [
        'Do not put all your eggs in one basket',
        'Our favorite holding period is forever',
        '1: Never lose money. 2: Never forget 1'
      ].sample
    end

    # def data
    #   @data ||= {}
    #             .merge(futures)
    #             .merge(indexes)
    #             .merge(
    #               'date_f': formatted_date,
    #               'time_f': formatted_time,
    #               'preheader_s': preheader
    #             )
    # end

    def elements
      [
        title,
        sp500_futures,
        nasdaq_futures,
        dowjones_futures,
        Templates::Element.divider,
        performance_title,
        Templates::Element.stats
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

    def item(key)
      data = Templates::Element::Item.new(
        title: ALIAS[key],
        value: futures[key]
      )

      Templates::Element.item(data)
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

    def futures
      @futures ||= Services::Futures.new.pre_market
    end
  end
end
