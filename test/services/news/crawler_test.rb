require './test/test_helper'
require './services/news/crawler'

module Services::News
  class CrawlerTest < Minitest::Test
    def test_stock
      skip "Not being used"
      VCR.use_cassette('crawler_stock') do
        items = Services::News::Crawler.stock('TWLO')

        assert_equal('[Services::News::DB::Item(keyword_init: true)]', items.collect(&:class).uniq.to_s)
      end
    end

    def test_reuters
      skip "Not being used"
      items = Services::News::Crawler.reuters
      assert_equal('[Services::News::DB::Item(keyword_init: true)]', items.collect(&:class).uniq.to_s)
    end
  end
end
