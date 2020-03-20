# frozen_string_literal: true

require 'minitest/autorun'
require './index'

class IndexTest < Minitest::Test
  def test_sq500_one_day
    Index.sp500.one_day
  end
end
