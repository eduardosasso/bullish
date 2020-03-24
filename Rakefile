# frozen_string_literal: true

require './bullish.rb'

task default: %w[test]

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = '*_test.rb'
end

task :send_email do
  Bullish.new.email_subscribers
end
