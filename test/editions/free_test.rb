# frozen_string_literal: true

require './test/test_helper'
require './editions/free'
require 'yaml'

module Editions
  class FreeTest < Minitest::Test
    def setup
      VCR.turn_off!
    end

    # just assert to make sure nothing is breaking
    def test_elements
      free = Editions::Free.new
      assert(free.elements)
    end

    def teardown
      VCR.turn_on!
    end
  end
end
