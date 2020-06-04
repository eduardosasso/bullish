# frozen_string_literal: true

require './test/test_helper'
require './services/top'

module Services
  class TopTest < Minitest::Test
    def setup
      @request_fixture = File.read('./test/fixtures/top_movers.json')
    end

    def top_movers(type)
      top = Services::Top.new

      top.stub(:request, JSON.parse(@request_fixture)) do
        movers = top.send(type)

        assert(movers.count.positive?)
        assert(movers.first.symbol)
        assert(movers.first.name)
        assert(movers.first.price)
      end
    end

    def test_losers
      top_movers('losers')
    end

    def test_gainers
      top_movers('gainers')
    end
  end
end
