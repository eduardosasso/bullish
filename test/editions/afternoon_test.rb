# frozen_string_literal: true

require './test/test_helper'
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

    def test_week_elements
      afternoon = Editions::Afternoon.new

      VCR.use_cassette('afternoon_edition_week_elements', :match_requests_on => [:method]) do
        Services::Ticker.any_instance.stubs(:news).returns({})

        Editions::Edition::DAY_ELEMENTS.each do |key, day_elements|
          assert(afternoon.send(day_elements))
        end
      end
    end

    def test_index_close
      sp500 = OpenStruct.new(price: 12, performance: '0.24%')
      nasdaq = OpenStruct.new(price: 32, performance: '-0.55%')
      dowjones = OpenStruct.new(price: 98, performance: '-0.04%')

      indexes = { sp500: sp500, nasdaq: nasdaq, dowjones: dowjones }

      afternoon = Editions::Afternoon.new

      afternoon.stub(:indexes, indexes) do
        assert_match(/#{indexes[:sp500].performance}/, afternoon.item_close(:sp500))
        assert_match(/#{indexes[:nasdaq].performance}/, afternoon.item_close(:nasdaq))
        assert_match(/#{indexes[:dowjones].performance}/, afternoon.item_close(:dowjones))
      end
    end

    def test_stats
      afternoon = Editions::Afternoon.new

      stubbed_top do
        assert(afternoon.top_gainers_performance)
        assert(afternoon.top_losers_performance)
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
          afternoon.stub(:todays_elements, []) do
            assert(afternoon.elements)
          end
        end
      end
    end

    def stubbed_top
      stats = { '1D' => '0.24%', '5D' => '0.05%', '1M' => '5.63%', '3M' => '-8.38%', '6M' => '-5.69%', '1Y' => '4.72%', '5Y' => '40.45%', '10Y' => '175.27%' }

      top = MiniTest::Mock.new
      top.expect(:gainers, [OpenStruct.new(symbol: 'KO', name: 'Coca-Cola', price: 1, performance: '10%', stats: stats)])
      top.expect(:losers, [OpenStruct.new(symbol: 'TSLA', name: 'Tesla', price: 2, performance: '20%', stats: stats)])

      Services::Top.stub(:new, top) do
        yield
      end
    end
  end
end
