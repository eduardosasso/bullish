# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr'
  config.hook_into :faraday
end

require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

require 'minitest/autorun'
require 'minitest/mock'
require 'mocha/minitest'
