# frozen_string_literal: true

require 'aws-sdk-s3'
require './services/log'
require 'dotenv/load'

module Services
  class Sample
    BUCKET = 'bullish-sample'
    PUBLIC = 'public-read'

    def upload(content)
      s3 = Aws::S3::Client.new
      s3.copy_object(bucket: BUCKET, copy_source: BUCKET + '/tomorrow.html', key: 'index.html', acl: PUBLIC)

      s3 = Aws::S3::Resource.new
      obj = s3.bucket(BUCKET).object('tomorrow.html')
      obj.put(body: content, acl: PUBLIC)
    rescue StandardError => e
      Services::Log.error(e.message)
    end
  end
end
