# frozen_string_literal: true

require 'minitest/autorun'
require './editions/afternoon'
require 'yaml'
require './services/top'

module Editions
  class AfternoonTest < Minitest::Test
    def test_subject
      indexes = { sp500: '-2.81%', nasdaq: '-3.2%', dowjones: '-2.55%' }

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
      indexes = { sp500: '0.24%', nasdaq: '-0.55%', dowjones: '-0.04%' }

      afternoon = Editions::Afternoon.new

      afternoon.stub(:indexes, indexes) do
        assert_match(/#{indexes[:sp500]}/, afternoon.sp500_close)
        assert_match(/#{indexes[:nasdaq]}/, afternoon.nasdaq_close)
        assert_match(/#{indexes[:dowjones]}/, afternoon.dowjones_close)
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
      indexes = { sp500: '0.24%', nasdaq: '-0.55%', dowjones: '-0.04%' }

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
