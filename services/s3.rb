# frozen_string_literal: true

require 'aws-sdk-s3'
require 'dotenv/load'
require 'active_support/all'

# https://docs.aws.amazon.com/sdk-for-ruby/v2/api/Aws/S3/Client.html
module Services
  class S3
    PUBLIC = 'public-read'

    def initialize(bucket)
      @bucket = bucket
    end

    def upload(name:, content:, tags: {}, acl: PUBLIC)
      s3 = Aws::S3::Resource.new

      s3.bucket(@bucket).tap do |s|
        s.put_object(
          key: name,
          body: content,
          tagging: tags.to_param,
          content_type: 'text/html',
          acl: acl
        )
      end
    end

    def copy(from:, to:, acl: PUBLIC)
      Aws::S3::Client.new.tap do |s|
        s.copy_object(
          bucket: @bucket,
          copy_source: @bucket + '/' + from,
          key: to,
          acl: acl
        )
      end
    end

    def list(options = {})
      options[:bucket] = @bucket

      Aws::S3::Client.new
                     .list_objects_v2(options)
                     .contents
                     .sort_by(&:last_modified)
                     .reverse
    end

    def list_folders
      options = {
        bucket: @bucket,
        delimiter: '/'
      }

      Aws::S3::Client.new.list_objects_v2(options)
                     .common_prefixes
                     .collect(&:prefix)
                     .sort
                     .reverse
    end

    def list_names(options = {})
      list(options).collect(&:key)
    end

    def tags(file)
      client = Aws::S3::Client.new

      list = {}

      client.get_object_tagging(
        bucket: @bucket,
        key: file
      ).tag_set.each do |tag|
        list[tag.key] = tag.value
      end

      list
    end
  end
end
