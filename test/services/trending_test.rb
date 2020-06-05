# frozen_string_literal: true

require './test/test_helper'
require './services/trending'

class TrendingTest < Minitest::Test
  def test_data
    VCR.use_cassette('trending') do
      trending = Services::Trending.new.stocks
      stock = trending.first

      assert(stock.symbol)
      assert_equal(Services::Trending::LIMIT, trending.count)
    end
  end
end
