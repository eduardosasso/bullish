# frozen_string_literal: true

require './test/test_helper'
require './editions/morning'

module Editions
  class MorningTest < Minitest::Test
    def setup
      ENV['MARKET_API'] = 'https://google.com'
    end

    def test_subject
      data = { 'nasdaq' => '-0.83%', 'sp500' => '1.65%', 'dowjones' => '2.58%' }

      Services::Futures.stub(:usa, data) do
        subject = Editions::Morning.new.subject
        assert_match(/Nasdaq|S&P 500|Dow Jones is/, subject)
      end
    end

    def test_index_futures
      data = { 'nasdaq' => '-0.83%', 'sp500' => '1.65%', 'dowjones' => '2.58%' }

      Services::Futures.stub(:usa, data) do
        morning = Editions::Morning.new

        assert(morning.sp500_futures)
        assert(morning.nasdaq_futures)
        assert(morning.dowjones_futures)
      end
    end

    def test_index_performance
      performance = { '1D' => '0.24%', '5D' => '0.05%', '1M' => '5.63%', '3M' => '-8.38%', '6M' => '-5.69%', '1Y' => '4.72%', '5Y' => '40.45%', '10Y' => '175.27%' }

      data = { 'nasdaq' => '-0.83%', 'sp500' => '1.65%', 'dowjones' => '2.58%' }

      ticker = MiniTest::Mock.new
      ticker.expect(:stats,  performance)
      ticker.expect(:stats,  performance)
      ticker.expect(:stats,  performance)
      ticker.expect(:price, 10)
      ticker.expect(:price, 10)
      ticker.expect(:price, 10)
      ticker.expect(:key, :sp500)
      ticker.expect(:key, :nasdaq)
      ticker.expect(:key, :dowjones)
      ticker.expect(:key, :sp500)
      ticker.expect(:key, :nasdaq)
      ticker.expect(:key, :dowjones)

      morning = Editions::Morning.new

      Services::Futures.stub(:usa, data) do
        Services::Ticker.stub(:new, ticker) do
          assert(morning.sp500_performance)
          assert(morning.nasdaq_performance)
          assert(morning.dowjones_performance)
        end
      end
    end

    def test_elements
      data = { 'nasdaq' => '-0.83%', 'sp500' => '1.65%', 'dowjones' => '2.58%' }

      morning = Editions::Morning.new

      Services::Futures.stub(:usa, data) do
        morning.stub(:todays_elements, []) do
          assert(morning.elements)
        end
      end
    end
  end
end
