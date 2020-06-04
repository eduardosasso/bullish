# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/test/'
end

require 'minitest/reporters'
# Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

require 'minitest/autorun'
