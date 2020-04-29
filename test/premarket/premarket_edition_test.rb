# frozen_string_literal: true

require 'minitest/autorun'
require './premarket/premarket_edition'

class PremarketEditionTest < Minitest::Test
  def test_subject
    futures = MiniTest::Mock.new
    futures.expect(:pre_market, 'nasdaq_f' => '-0.83%', 'sp500_f' => '1.65%', 'dowjones_f' => '2.58%')

    Futures.stub(:new, futures) do
      subject = PremarketEdition.new.subject
      assert_match(/Nasdaq|S&P 500|Dow Jones is/, subject)
    end
  end

  def test_futures
    futures_data = File.read('./test/futures.json')

    Net::HTTP.stub(:get, futures_data) do
      assert_equal(%w[nasdaq_f sp500_f dowjones_f].sort, PremarketEdition.new.futures.keys.sort)
    end
  end

  def test_template
    assert(PremarketEdition.new.template)
  end
end
