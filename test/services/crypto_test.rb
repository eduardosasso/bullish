# frozen_string_literal: true

require './test/test_helper'
require './services/crypto'

class CryptoTest < Minitest::Test
  def test_data
    VCR.use_cassette('crypto') do
      cryptos = Services::Crypto.data
      coin = cryptos.first

      assert(coin.symbol)
      assert(coin.performance)
      assert(coin.stats)
      assert(coin.price)
      assert(coin.name)

      assert_equal(Services::Crypto::COINS.count, cryptos.count)
    end
  end
end
