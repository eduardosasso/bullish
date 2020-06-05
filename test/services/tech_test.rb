# frozen_string_literal: true

require './test/test_helper'
require './services/tech'

class TechTest < Minitest::Test
  def test_data
    VCR.use_cassette('tech') do
      tech = Services::Tech.data
      stock = tech.first

      assert(stock.symbol)
      assert(stock.performance)
      assert(stock.stats)
      assert(stock.price)
      assert(stock.name)

      assert_equal(Services::Tech::LIST.count, tech.count)
    end
  end
end
