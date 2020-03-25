# frozen_string_literal: true

require './email'
require './template'
require './futures'
require './ticker'

# buy high sell low
class Bullish
  def initialize(test = ENV['TEST'])
    Dotenv.load

    @test = test
  end

  def post
    Email.new(subject, content).post
  end

  def subject; end

  def content
    Template.new(data).compile
  end

  def data
    {}.merge(futures).merge(indexes)
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
