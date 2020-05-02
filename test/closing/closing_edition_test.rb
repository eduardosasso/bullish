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
      data = ClosingEdition.new.data

      assert(data[:date_c])
      assert(data[:preheader_s])
    end
  end

  def test_subject
    stubbed_top do
      assert(ClosingEdition.new.subject)
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
