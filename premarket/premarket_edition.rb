# frozen_string_literal: true

require './edition'
require './premarket/futures'
require './template'

class PremarketEdition < Edition
  def subject
    sample = futures.to_a.sample(1).to_h
    key = sample.keys.first.gsub('_f', '')
    value = sample.values.first

    up_down = value.start_with?(Template::MINUS) ? 'down' : 'up'

    "#{ALIAS[key.to_sym]} is #{up_down} #{value} in premarket"
  end

  def preheader
    [
      'Do not put all your eggs in one basket',
      'Our favorite holding period is forever',
      '1: Never lose money. 2: Never forget 1'
    ].sample
  end

  def data
    @data ||= {}
              .merge(futures)
              .merge(indexes)
              .merge(
                'date_f': formatted_date,
                'time_f': formatted_time,
                'preheader_s': preheader
              )
  end

  def template
    File.read('premarket/template.html')
  end

  def subscribers_group_id
    ENV['FREE_GROUP']
  end

  # rewrite to conform to template data reqs
  # nasdaq to nasdaq_f, sp500 to sp500_f
  def futures
    {}.tap do |h|
      Futures.pre_market.each do |key, value|
        h["#{key}_f"] = value
      end
    end
  end
end
