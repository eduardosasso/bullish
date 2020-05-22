# frozen_string_literal: true

require 'minitest/autorun'
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

    def test_indexes
      vars = []

      Services::Ticker::INDEX.keys.each do |index|
        vars << Services::Ticker::RANGE.keys.map do |period|
          "#{index}_#{period}"
        end
      end

      performance = {
        "1D": 0.44,
        "5D": 2.5,
        "1M": -21.42,
        "3M": -24.13,
        "6M": -17.65,
        "1Y": -12.16,
        "5Y": 19.26,
        "10Y": 110.86
      }

      ticker = MiniTest::Mock.new
      ticker.expect(:full_performance, performance)
      ticker.expect(:full_performance, performance)
      ticker.expect(:full_performance, performance)

      Services::Ticker.stub(:new, ticker) do
        assert_equal(vars.flatten.sort, Editions::Edition.new.indexes.keys.sort)
      end
    end
  end
end
