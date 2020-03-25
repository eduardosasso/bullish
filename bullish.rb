# frozen_string_literal: true

require './email'
require './template'
require './futures'
require './ticker'
require 'raven'

# buy high sell low
class Bullish
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

  def subject; end

  def content
    Template.new(data).compile
  end

  def data
    @data ||= {}.merge(futures).merge(indexes)
  end

  # rewrite to conform to template data reqs
  # nasdaq to nasdaq_1D, sp500_3M...
  def indexes
    keys = Ticker::INDEX.keys

    keys.each_with_object({}) do |index, hash|
      Ticker.send(index).performance.each do |key, value|
        hash["#{index}_#{key}"] = value.to_s + '%'
      end
    end
  end

  # rewrite to conform to template data reqs
  # nasdaq to nasdaq_f, sp500 to sp500_f
  def futures
    {}.tap do |h|
      Futures.pre_market.each do |key, value|
        h["#{key}_f"] = value.to_s + '%'
      end
    end
  end
end
