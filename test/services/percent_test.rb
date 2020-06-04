# frozen_string_literal: true

require './test/test_helper'
require 'minitest/mock'
require './services/percent'

class TickerTest < Minitest::Test
  def test_diff
    assert_equal('11.11%', Services::Percent.diff(100, 90).to_s)
  end
end
