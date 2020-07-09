# frozen_string_literal: true

require './test/test_helper'
require './editions/free'
require 'yaml'

module Editions
  class FreeTest < Minitest::Test
    # just assert to make sure nothing is breaking
    VCR.turn_off!
    def test_elements
        free = Editions::Free.new

        assert(free.elements)
    end
  end
end
