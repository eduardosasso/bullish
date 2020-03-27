# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require './ticker'
require 'active_support/testing/time_helpers'
# require 'timecop'

class TickerTest < Minitest::Test
  include ActiveSupport::Testing::TimeHelpers

  def setup
    @request_fixture = File.read('./test/sp500.json')
    travel_to Date.parse('2020-03-24')
  end

  def test_performance
    ticker = Ticker.sp500

    ticker.request = @request_fixture

    assert_equal(Ticker.period.keys, ticker.performance.keys)
    assert_equal(Ticker.period.keys.count, ticker.performance.values.compact.count)
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
