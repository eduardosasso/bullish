# frozen_string_literal: true

require './test/test_helper'
require './editions/edition'
require './templates/element'

module Editions
  class EditionTest < Minitest::Test
    def test_content
      edition = Editions::Edition.new
      data = Templates::Element::Title.new(title: 'Bitcoin')
      element = Templates::Element.title(data)

      edition.stub(:elements, [element]) do
        edition.stub(:preheader, 'preheader sentence') do
          content = edition.content
          assert_match(/<!doctype html>/, content)
          assert_match(/Bitcoin/, content)
          assert_match(/preheader sentence/, content)
        end
      end
    end

    def test_todays_elements
      edition = Editions::Edition.new

      method = Editions::Edition::DAY_ELEMENTS[edition.day_of_the_week.to_sym]

      edition.stub(method, edition.day_of_the_week) do
        assert_equal(edition.day_of_the_week, edition.todays_elements)
      end
    end
  end
end
