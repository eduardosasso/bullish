# frozen_string_literal: true

require 'minitest/autorun'
require './editions/afternoon'
require 'yaml'
require './services/top'

module Editions
  class AfternoonTest < Minitest::Test
    def test_gainers
      stubbed_top do
        Editions::Afternoon.new.gainers.tap do |c|
          assert(c['gainers1_s'])
          assert(c['gainers3_10Y'])
          assert(c['gainers2_6M'])
        end
      end
    end

    def test_data
      stubbed_top do
        closing_edition = Editions::Afternoon.new
        closing_edition.stub(:indexes, {}) do
          data = closing_edition.data
          assert(data[:date_c])
          assert(data[:preheader_s])
        end
      end
    end

    def test_subject
      indexes = { sp500_c: '-2.81%', nasdaq_c: '-3.2%', dowjones_c: '-2.55%' }

      stubbed_top do
        closing_edition = Editions::Afternoon.new
        closing_edition.stub(:indexes, indexes) do
          assert(closing_edition.subject)
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
