
require './test/test_helper'
require './services/archive'
require 'aws-sdk-s3'
require './services/s3'
require 'faraday'

module Services
  class ArchiveTest < Minitest::Test
    def test_upload
      mock = MiniTest::Mock.new

      name = "#{Services::Archive::FOLDER}/nasdaq-is-up-2.html"
      content = "Content"

      Services::Popup.any_instance.stubs(:inject).returns(content)

      tags = {:subject_base64=>"TmFzZGFxIGlzIHVwIDIl"}

      mock.expect(:upload, nil, [name: name, content: content, tags: tags])

      Services::S3.stub :new, mock do
        Services::Archive.new.upload('Nasdaq is up 2%', 'Content')
      end

      mock.verify
    end

    def test_build_index
      archive = Services::Archive.new

      subject = "Nasdaq is up #{rand(1..8)}% today"

      archive.upload(subject, '<head></head>email content')

      archive.build_index

      bucket_url = 'https://bullish-archive-test.s3-us-west-2.amazonaws.com/'

      index = Faraday.get(bucket_url + 'index.html').body

      assert_match(subject, index)

      name = subject.parameterize.dasherize

      response = Faraday.get("#{bucket_url}#{Archive::FOLDER}/#{name}.html")

      assert(response.success?)
    end
  end
end
