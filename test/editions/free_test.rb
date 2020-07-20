# frozen_string_literal: true

require './test/test_helper'
require './editions/free'
require 'yaml'

module Editions
  class FreeTest < Minitest::Test
    # just assert to make sure nothing is breaking
    # def test_elements
    #   VCR.use_cassette('free_edition_elements', :match_requests_on => [:method]) do
    #     free = Editions::Free.new
    #     assert(free.elements)
    #   end
    # end
  end
end
