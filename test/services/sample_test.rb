
require './test/test_helper'
require './services/sample'
require 'faraday'

module Services
  class SampleTest < Minitest::Test
    def test_upload
      sample = Services::Sample.new
      
      content = Time.now.to_s

      sample.upload(content)

      bucket_url = 'https://bullish-sample-test.s3-us-west-2.amazonaws.com/'

      tomorrow = Faraday.get(bucket_url + 'tomorrow.html').body

      assert_match(content, tomorrow)
    end
  end
end
