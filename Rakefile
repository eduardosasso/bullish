# frozen_string_literal: true

require './bullish.rb'

task default: %w[test]

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
end

task :send_free_edition do
  Bullish.free_edition.post
end

task :send_morning_edition do
  Bullish.morning_edition.post
end

task :send_afternoon_edition do
  Bullish.afternoon_edition.post
end

task :preview_free_email do
  day = ARGV[1]

  bullish = Bullish.free_edition

  preview_email(bullish, day)

  exit
end

task :preview_morning_email do
  day = ARGV[1]

  bullish = Bullish.morning_edition

  preview_email(bullish, day)

  exit
end

task :preview_afternoon_email do
  day = ARGV[1]

  bullish = Bullish.afternoon_edition

  preview_email(bullish, day)

  exit
end

def preview_email(bullish, day = nil)
  bullish.edition.day_of_the_week = day if day

  bullish.save
end
