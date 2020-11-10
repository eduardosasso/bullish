require './test/test_helper'
require './services/news/crawler'

module Services::News
  class CrawlerTest < Minitest::Test
    def test_stock
      VCR.use_cassette('crawler_stock') do
        items = Services::News::Crawler.stock('TWLO')

        assert_equal('[Services::News::DB::Item(keyword_init: true)]', items.collect(&:class).uniq.to_s)
      end
    end
  end
end
