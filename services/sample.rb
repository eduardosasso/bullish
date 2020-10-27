# frozen_string_literal: true

require './services/s3'
require './services/config'

module Services
  class Sample
    BUCKET = 'bullish-sample'

    def initialize(bucket = BUCKET)
      @bucket = bucket

      @bucket += '-test' if Services::Config.test?
    end

    def upload(content)
      s3 = Services::S3.new(@bucket)

      begin
        s3.copy(from: 'tomorrow.html', to: 'index.html')
      rescue StandardError
        nil
      end

      s3.upload(name: 'tomorrow.html', content: content)
    end
  end
end
