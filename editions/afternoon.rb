# frozen_string_literal: true

require './editions/edition'
require './services/top'

module Editions
  class Afternoon < Edition
    def subject
      sample = indexes.to_a.sample(1).to_h
      key = sample.keys.first.to_s.gsub('_c', '')
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
      trending = {}.merge(gainers).merge(losers)

      type = %w[gainers losers].sample
      i = [1, 2, 3].sample.to_s

      name = trending.dig("#{type}#{i}_n")
      value = trending.dig("#{type}#{i}_1D")
      price = trending.dig("#{type}#{i}_p")

      value = "#{value} to #{price}"

      if type == 'gainers'
        subject_up(name, value)
      else
        subject_down(name, value)
      end
    end

    def data
      @data ||= {}
                .merge(indexes)
                .merge(gainers)
                .merge(losers)
                .merge(
                  'date_c': formatted_date,
                  'time_c': formatted_time,
                  'preheader_s': preheader
                )
    end

    def indexes
      @indexes ||= {
        'sp500_c': Services::Ticker.sp500.performance.to_s + '%',
        'nasdaq_c': Services::Ticker.nasdaq.performance.to_s + '%',
        'dowjones_c': Services::Ticker.dowjones.performance.to_s + '%'
      }
    end

    def gainers
      @gainers ||= top('gainers')
    end

    def losers
      @losers ||= top('losers')
    end

    def top(type)
      i = 1

      Services::Top.new.send(type).each_with_object({}) do |item, hash|
        price = '$' + item.price.to_s

        hash["#{type}#{i}_s"] = item.ticker + ' · ' + price
        hash["#{type}#{i}_n"] = item.name
        hash["#{type}#{i}_p"] = price

        item.performance.each_pair do |key, value|
          hash["#{type}#{i}_#{key}"] = value.to_s + '%'
        end

        i += 1
      end
    end

    def subscribers_group_id
      ENV['PREMIUM_GROUP']
    end

    def template
      File.read('closing/template.html')
    end
  end
end
