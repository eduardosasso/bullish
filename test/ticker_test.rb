# frozen_string_literal: true

require 'minitest/autorun'
require './ticker'

class TickerTest < Minitest::Test
  def setup
    @request_fixture = File.read('./test/sp500.json')
  end

  def test_performance
    ticker = Ticker.sp500

    ticker.request = @request_fixture

    assert_equal(Ticker::PERIOD.keys, ticker.performance.keys)
    assert_equal(Ticker::PERIOD.keys.count, ticker.performance.values.compact.count)
  end

  def test_performance_error
    ticker = Ticker.dowjones
    ticker.request = @request_fixture

    assert_raises(RuntimeError) { ticker.performance_by_period(25.years.ago) }
  end

  def test_percent_change
    ticker = Ticker.dowjones

    assert_equal(11.11, ticker.percent_change(100, 90))
  end
end
