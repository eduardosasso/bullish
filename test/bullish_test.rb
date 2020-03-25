# frozen_string_literal: true

require 'minitest/autorun'
require './bullish'

class BullishTest < Minitest::Test
  def setup
    ENV['TEST'] = 'true'
  end

  def test_futures
    # TODO: stub futures bypass api
    assert_equal(%w[nasdaq_f sp500_f dowjones_f].sort, Bullish.new.futures.keys.sort)
  end

  def test_indexes
    vars = []

    Ticker::INDEX.keys.each do |index|
      vars << Ticker::PERIOD.keys.map do |period|
        "#{index}_#{period}"
      end
    end

    # TODO: stub performance to not hit api
    assert_equal(vars.flatten.sort, Bullish.new.indexes.keys.sort)
  end
end
