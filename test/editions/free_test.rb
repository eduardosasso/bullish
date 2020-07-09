# frozen_string_literal: true

require './test/test_helper'
require './editions/free'
require 'yaml'

module Editions
  class FreeTest < Minitest::Test
    # just assert to make sure nothing is breaking
    # def test_elements
    #   VCR.turn_off!
    #   free = Editions::Free.new

    #   assert(free.elements)
    #   VCR.turn_on!
    # end
  end
end
