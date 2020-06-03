# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require './services/fifty_two_week'
require './services/ticker'
require 'faraday'

class FiftyTwoWeekTest < Minitest::Test
  def test_down_from_high
    s = Services::FiftyTwoWeek.new(Services::Ticker::INDEX[:bitcoin])

    p "#{s.down_from_high} - high #{s.high_value} - current #{s.current_value}"
    p "#{s.up_from_low} - low #{s.low_value} - current #{s.current_value}"

  end
end
