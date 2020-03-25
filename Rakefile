# frozen_string_literal: true

require './bullish.rb'

task default: %w[test]

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'test/*_test.rb'
end

task :send_email do
  Bullish.post
end
