require './test/test_helper'
require './services/news/db'

module Services::News
  class DBTest < Minitest::Test
    def test_find
      VCR.use_cassette('news_stock_find') do
        item = Services::News::DB.find('PINS')
        assert_equal('Services::News::DB::Item', item.class.to_s)
      end
    end
  end
end
