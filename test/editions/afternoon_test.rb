# frozen_string_literal: true

require 'minitest/autorun'
require './editions/afternoon'
require 'yaml'
require './services/top'

module Editions
  class AfternoonTest < Minitest::Test
    def test_subject
      sp500 = OpenStruct.new(price: 12, performance: '-2.81%')
      nasdaq = OpenStruct.new(price: 32, performance: '-3.2%')
      dowjones = OpenStruct.new(price: 98, performance: '-2.55%')

      indexes = { sp500: sp500, nasdaq: nasdaq, dowjones: dowjones }

      stubbed_top do
        afternoon = Editions::Afternoon.new
        afternoon.stub(:indexes, indexes) do
          assert(afternoon.subject)
        end
      end
    end

    def test_preheader
      stubbed_top do
        assert(Editions::Afternoon.new.preheader)
      end
    end

    def test_index_close
      sp500 = OpenStruct.new(price: 12, performance: '0.24%')
      nasdaq = OpenStruct.new(price: 32, performance: '-0.55%')
      dowjones = OpenStruct.new(price: 98, performance: '-0.04%')

      indexes = { sp500: sp500, nasdaq: nasdaq, dowjones: dowjones }

      afternoon = Editions::Afternoon.new

      afternoon.stub(:indexes, indexes) do
        assert_match(/#{indexes[:sp500].performance}/, afternoon.sp500_close)
        assert_match(/#{indexes[:nasdaq].performance}/, afternoon.nasdaq_close)
        assert_match(/#{indexes[:dowjones].performance}/, afternoon.dowjones_close)
      end
    end

    def test_stats
      afternoon = Editions::Afternoon.new

      stubbed_top do
        assert(afternoon.gainers_performance)
        assert(afternoon.losers_performance)
      end
    end

    def test_elements
      sp500 = OpenStruct.new(price: 12, performance: '0.24%')
      nasdaq = OpenStruct.new(price: 32, performance: '-0.55%')
      dowjones = OpenStruct.new(price: 98, performance: '-0.04%')

      indexes = { sp500: sp500, nasdaq: nasdaq, dowjones: dowjones }

      afternoon = Editions::Afternoon.new

      stubbed_top do
        afternoon.stub(:indexes, indexes) do
          assert(afternoon.elements)
        end
      end
    end

    def stubbed_top
      gainers = YAML.safe_load(YAML.load_file('./test/fixtures/gainers'), permitted_classes: [Services::Ticker::Detail, Symbol])
      losers = YAML.safe_load(YAML.load_file('./test/fixtures/losers'), permitted_classes: [Services::Ticker::Detail, Symbol])

      top = MiniTest::Mock.new
      top.expect(:gainers, gainers)
      top.expect(:losers, losers)

      Services::Top.stub(:new, top) do
        yield
      end
    end
  end
end
