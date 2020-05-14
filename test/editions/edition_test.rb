# frozen_string_literal: true

require 'minitest/autorun'
require './editions/edition'

module Editions
  class EditionTest < Minitest::Test
    def test_content
      data = { ibm_5d: '300%' }
      # template = 'IBM: ibm_5d'

      edition = Editions::Edition.new

      edition.stub(:layout, ['{{ibm_5d}}']) do
        edition.stub(:data, data) do
          assert_match(/300%/, edition.content)
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
