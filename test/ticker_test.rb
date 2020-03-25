# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require './ticker'

class TickerTest < Minitest::Test
  def setup
    @request_fixture = File.read('./test/sp500.json')
  end

  def test_performance
    ticker = Ticker.sp500

    ticker.request = @request_fixture

    Ticker.stub(:current_date, '2020-03-24') do
      assert_equal(Ticker::PERIOD.keys, ticker.performance.keys)
      assert_equal(Ticker::PERIOD.keys.count, ticker.performance.values.compact.count)
    end
  end

  def test_performance_error
    ticker = Ticker.dowjones
    ticker.request = @request_fixture

    Ticker.stub(:current_date, '2020-03-24') do
      assert_raises(RuntimeError) { ticker.performance_by_period(25.years.ago) }
    end
  end

  def test_percent_change
    ticker = Ticker.dowjones

    assert_equal(11.11, ticker.percent_change(100, 90))
  end
end
