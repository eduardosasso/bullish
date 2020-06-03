# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require './services/peak'

class PeakTest< Minitest::Test
  def test_value
     peak = Services::Peak.new('^GSPC')
     p peak.max_value
     p peak.current_value
     p peak.date
     p peak.diff
     p peak.quotes.last(10)
  end
end
