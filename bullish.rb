# frozen_string_literal: true

require './email'
require './template'
require './futures'
require './ticker'
require 'raven'

# buy high sell low
class Bullish
  MINUS = '-'

  ALIAS = {
    'sp500': 'S&P 500',
    'nasdaq': 'Nasdaq',
    'dowjones': 'Dow Jones'
  }.freeze

  def initialize(test = ENV['TEST'])
    Dotenv.load

    @test = test
  end

  # send email to subscribers
  # retry 3 times when fail
  def self.post
    retries ||= 0

    bullish = Bullish.new

    Email.new(bullish.subject, bullish.content).post
  rescue StandardError => e
    retries += 1
    retry if retries < 3

    Raven.capture_message(e.message)

    raise e
  end

  def subject
    sample = futures.to_a.sample(1).to_h
    key = sample.keys.first.gsub('_f', '')
    value = sample.values.first

    up_down = value.start_with?(MINUS) ? '' : '+'

    "Pre-Market for #{ALIAS[key.to_sym]} is #{up_down}#{value}"
  end

  def content
    Template.new(data).compile
  end

  # date time in ET where markets operate
  def date_time_et
    DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)')
  end

  def data
    @data ||= {}
              .merge(futures)
              .merge(indexes)
              .merge(
                'date_f': date_time_et.strftime('%B %d, %Y'),
                'time_f': date_time_et.strftime('%I:%M%p ET')
              )
  end

  # rewrite to conform to template data reqs
  # nasdaq to nasdaq_1D, sp500_3M...
  def indexes
    keys = Ticker::INDEX.keys

    keys.each_with_object({}) do |index, hash|
      Ticker.send(index).performance.each do |key, value|
        hash["#{index}_#{key}"] = value
      end
    end
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
