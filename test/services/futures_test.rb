# frozen_string_literal: true

require 'minitest/autorun'
require './services/futures'

module Services
  class FuturesTest < Minitest::Test
    def test_usa
      futures = MiniTest::Mock.new
      futures.expect(:data, { 'nasdaq': '-0.83%', 'sp500': '1.65%', 'dowjones': '2.58%' }, [Hash])
      futures.expect(:data, { 'nasdaq': '-0.83%', 'sp500': '1.65%', 'dowjones': '2.58%' }, [Hash])

      Services::Futures.stub(:new, futures) do
        assert_equal(Services::Futures::USA.keys.sort, Services::Futures.usa.keys.sort)
        assert_equal(Services::Futures::USA.keys.count, Services::Futures.usa.values.compact.count)
      end
    end

    def test_world
      futures = MiniTest::Mock.new
      futures.expect(:data, { nikkei: '-0.23%', ftse: '1.83%', dax: '-1.15%' }, [Hash])
      futures.expect(:data, { nikkei: '-0.23%', ftse: '1.83%', dax: '-1.15%' }, [Hash])

      Services::Futures.stub(:new, futures) do
        assert_equal(Services::Futures::WORLD.keys.sort, Services::Futures.world.keys.sort)
        assert_equal(Services::Futures::WORLD.keys.count, Services::Futures.world.values.compact.count)
      end
    end
  end
end
