# frozen_string_literal: true

require 'minitest/autorun'
require './editions/morning'

module Editions
  class MorningTest < Minitest::Test
    def setup
      ENV['MARKET_API'] = 'https://google.com'
    end

    def test_subject
      futures = MiniTest::Mock.new
      futures.expect(:pre_market, 'nasdaq' => '-0.83%', 'sp500' => '1.65%', 'dowjones' => '2.58%')

      Services::Futures.stub(:new, futures) do
        subject = Editions::Morning.new.subject
        assert_match(/Nasdaq|S&P 500|Dow Jones is/, subject)
      end
    end

    def test_index_futures
      futures = MiniTest::Mock.new
      futures.expect(:pre_market, 'nasdaq' => '-0.83%', 'sp500' => '1.65%', 'dowjones' => '2.58%')

      Services::Futures.stub(:new, futures) do
        morning = Editions::Morning.new

        assert(morning.sp500_futures)
        assert(morning.nasdaq_futures)
        assert(morning.dowjones_futures)
      end
    end

    def test_index_performance
      performance = { '1D' => '0.24%', '5D' => '0.05%', '1M' => '5.63%', '3M' => '-8.38%', '6M' => '-5.69%', '1Y' => '4.72%', '5Y' => '40.45%', '10Y' => '175.27%' }

      morning = Editions::Morning.new
      morning.stub(:performance, performance) do
        assert(morning.sp500_performance)
        assert(morning.nasdaq_performance)
        assert(morning.dowjones_performance)
      end
    end

    def test_elements
      performance = { '1D' => '0.24%', '5D' => '0.05%', '1M' => '5.63%', '3M' => '-8.38%', '6M' => '-5.69%', '1Y' => '4.72%', '5Y' => '40.45%', '10Y' => '175.27%' }

      futures = MiniTest::Mock.new
      futures.expect(:pre_market, 'nasdaq' => '-0.83%', 'sp500' => '1.65%', 'dowjones' => '2.58%')

      Services::Futures.stub(:new, futures) do
        morning = Editions::Morning.new
        morning.stub(:performance, performance) do
          assert(morning.elements)
        end
      end
    end
  end
end
