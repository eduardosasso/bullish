# frozen_string_literal: true

require './test/test_helper'
require './services/world'

class WorldTest < Minitest::Test
  def test_data
    VCR.use_cassette('world') do
      world = Services::World.data
      index = world.first

      assert(index.symbol)
      assert(index.performance)
      assert(index.stats)
      assert(index.price)
      assert(index.name)

      assert_equal(Services::World::LIST.count, world.count)
    end
  end
end
