# frozen_string_literal: true

require 'minitest/autorun'
require './futures'

class FuturesTest < Minitest::Test
  def test_pre_market
    futures = MiniTest::Mock.new
    futures.expect(:pre_market, 'nasdaq': '-0.83%', 'sp500': '1.65%', 'dowjones': '2.58%')
    futures.expect(:pre_market, 'nasdaq': '-0.83%', 'sp500': '1.65%', 'dowjones': '2.58%')

    Futures.stub(:new, futures) do
      assert_equal(Futures::INDEX.keys.sort, Futures.pre_market.keys.sort)
      assert_equal(Futures::INDEX.keys.count, Futures.pre_market.values.compact.count)
    end
  end
end
