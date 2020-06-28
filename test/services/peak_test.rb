# frozen_string_literal: true

require './test/test_helper'
require './services/peak'

class PeakTest < Minitest::Test
  def test_all_time_high
    VCR.use_cassette('peak', match_requests_on: %i[host path]) do
      peak = Services::Peak.new('^GSPC')

      assert(peak.max_value)
      assert(peak.current_value)
      assert(peak.date)
      assert(peak.diff)
      assert_equal(10, peak.quotes.last(10).count)
    end
  end
end
