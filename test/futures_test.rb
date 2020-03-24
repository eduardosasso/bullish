# frozen_string_literal: true

require 'minitest/autorun'
require './futures'

class FuturesTest < Minitest::Test
  def test_pre_market
    assert_equal(Futures::INDEX.keys.sort, Futures.pre_market.keys.sort)
    assert_equal(Futures::INDEX.keys.count, Futures.pre_market.values.compact.count)
  end
end
