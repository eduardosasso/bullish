# frozen_string_literal: true

require './test/test_helper'
require './services/sector'

class SectorTest < Minitest::Test
  def test_data
    VCR.use_cassette('sector') do
      sector = Services::Sector.data
      etf = sector.first

      assert(etf.symbol)
      assert(etf.performance)
      assert(etf.stats)
      assert(etf.price)
      assert(etf.name)

      assert_equal(Services::Sector::LIST.count, sector.count)
    end
  end
end
