# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require './services/ticker'

module Services
  class TickerTest < Minitest::Test
    def setup
      @request_fixture = File.read('./test/fixtures/sp500.json')
    end

    def test_performance
      log = MiniTest::Mock.new
      log.expect(:log, 'nil')

      Services::Ticker.sp500('5d').stub(:log, log) do |ticker|
        ticker.stub(:request, @request_fixture) do
          assert(ticker.performance)
        end
      end
    end

    def test_stats
      perf = MiniTest::Mock.new

      perf.expect(:performance, '1D')
      perf.expect(:performance, '5D')
      perf.expect(:performance, '1M')
      perf.expect(:performance, '3M')
      perf.expect(:performance, '6M')
      perf.expect(:performance, '1Y')
      perf.expect(:performance, '5Y')
      perf.expect(:performance, '10Y')

      nasdaq = Services::Ticker.nasdaq

      Services::Ticker.stub(:new, perf) do
        assert_equal(Services::Ticker::RANGE.keys.count, nasdaq.stats.values.compact.count)
      end
    end
  end
end
