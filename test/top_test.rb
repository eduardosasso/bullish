# frozen_string_literal: true

require 'minitest/autorun'
require './top'

class TopTest < Minitest::Test
  def setup
    @request_fixture = File.read('./test/top_movers.json')
  end

  def top_movers(type)
    top = Top.new

    top.stub(:request, JSON.parse(@request_fixture)) do
      top.stub(:performance, nil) do
        movers = top.send(type)

        assert(movers.count.positive?)
        assert(movers.first.ticker)
        assert(movers.first.name)
        assert(movers.first.price)
        assert(movers.first.percent)
      end
    end
  end

  def test_losers
    top_movers('losers')
  end

  def test_gainers
    top_movers('gainers')
  end
end
