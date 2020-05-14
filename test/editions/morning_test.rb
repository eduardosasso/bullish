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
      futures.expect(:pre_market, 'nasdaq_f' => '-0.83%', 'sp500_f' => '1.65%', 'dowjones_f' => '2.58%')

      Services::Futures.stub(:new, futures) do
        subject = Editions::Morning.new.subject
        assert_match(/Nasdaq|S&P 500|Dow Jones is/, subject)
      end
    end

    def test_futures
      futures_data = File.read('./test/fixtures/futures.json')

      Net::HTTP.stub(:get, futures_data) do
        assert_equal(%w[nasdaq_f sp500_f dowjones_f].sort, Editions::Morning.new.futures.keys.sort)
      end
    end

    def test_layout
      assert(Editions::Morning.new.layout)
    end
  end
end
