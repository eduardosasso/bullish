# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require './ticker'
require 'faraday'

class TickerTest < Minitest::Test
  def setup
    @request_fixture = File.read('./test/sp500.json')
  end

  def test_performance
    ticker = Ticker.sp500('5d')

    ticker.request = @request_fixture

    assert(ticker.performance)
  end

  def test_full_performance
    perf = MiniTest::Mock.new

    perf.expect(:performance, '1D')
    perf.expect(:performance, '5D')
    perf.expect(:performance, '1M')
    perf.expect(:performance, '3M')
    perf.expect(:performance, '6M')
    perf.expect(:performance, '1Y')
    perf.expect(:performance, '5Y')
    perf.expect(:performance, '10Y')

    nasdaq = Ticker.nasdaq

    Ticker.stub(:new, perf) do
      assert_equal(Ticker::RANGE.keys.count, nasdaq.full_performance.values.compact.count)
    end
  end

  def test_percent_change
    ticker = Ticker.dowjones

    assert_equal(11.11, ticker.percent_change(100, 90))
  end
end
