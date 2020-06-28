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
  end
end
