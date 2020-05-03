# frozen_string_literal: true

require 'minitest/autorun'
require './closing/closing_edition'
require 'yaml'
require './top'

class ClosingEditionTest < Minitest::Test
  def test_gainers
    stubbed_top do
      ClosingEdition.new.gainers.tap do |c|
        assert(c['gainers1_s'])
        assert(c['gainers3_10Y'])
        assert(c['gainers2_6M'])
      end
    end
  end

  def test_data
    stubbed_top do
      closing_edition = ClosingEdition.new
      closing_edition.stub(:indexes, {}) do 
        data = closing_edition.data
        assert(data[:date_c])
        assert(data[:preheader_s])
      end
    end
  end

  def test_subject
    indexes = {:sp500_c=>"-2.81%", :nasdaq_c=>"-3.2%", :dowjones_c=>"-2.55%"}

    stubbed_top do
      closing_edition = ClosingEdition.new
      closing_edition.stub(:indexes, indexes) do 
        assert(closing_edition.subject)
      end
    end
  end

  def stubbed_top
    gainers = YAML.safe_load(YAML.load_file('./test/fixtures/gainers'), permitted_classes: [Top::Mover, Symbol])
    losers = YAML.safe_load(YAML.load_file('./test/fixtures/losers'), permitted_classes: [Top::Mover, Symbol])

    top = MiniTest::Mock.new
    top.expect(:gainers, gainers)
    top.expect(:losers, losers)

    Top.stub(:new, top) do
      yield
    end
  end
end
