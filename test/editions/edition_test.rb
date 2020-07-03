# frozen_string_literal: true

require './test/test_helper'
require './editions/morning'
require './editions/free'
require './templates/element'

module Editions
  class EditionTest < Minitest::Test
    def test_content
      edition = Editions::Morning.new
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

    def test_premium?
      edition = Editions::Morning.new

      assert(edition.premium?)
    end

    def test_not_premium?
      edition = Editions::Free.new

      refute(edition.premium?)
    end
  end
end
