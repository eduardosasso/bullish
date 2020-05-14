# frozen_string_literal: true

require 'minitest/autorun'
require './services/futures'

module Services
  class FuturesTest < Minitest::Test
    def test_pre_market
      futures = MiniTest::Mock.new
      futures.expect(:pre_market, 'nasdaq': '-0.83%', 'sp500': '1.65%', 'dowjones': '2.58%')
      futures.expect(:pre_market, 'nasdaq': '-0.83%', 'sp500': '1.65%', 'dowjones': '2.58%')

      Services::Futures.stub(:new, futures) do
        assert_equal(Services::Futures::INDEX.keys.sort, Services::Futures.pre_market.keys.sort)
        assert_equal(Services::Futures::INDEX.keys.count, Services::Futures.pre_market.values.compact.count)
      end
    end
  end
end
