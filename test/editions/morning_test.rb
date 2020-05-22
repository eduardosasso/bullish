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
  end
end
