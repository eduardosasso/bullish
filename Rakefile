# frozen_string_literal: true

require './bullish.rb'

task default: %w[test]

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*_test.rb'
end

task :send_free_edition do
  day = ARGV[1]

  send_email(Bullish.free_edition, day)
end

task :send_morning_edition do
  day = ARGV[1]

  send_email(Bullish.morning_edition, day)
end

task :send_afternoon_edition do
  day = ARGV[1]

  send_email(Bullish.afternoon_edition, day)
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

task :preview_all do
  Editions::Edition::DAY_ELEMENTS.each do |day, value|
    puts '- ' + day.to_s + ' free'
    free = Bullish.free_edition
    free.edition.day_of_the_week = day 
    free.edition.save(day.to_s + '-free')

    puts '- ' + day.to_s + ' morning'
    morning = Bullish.morning_edition
    morning.edition.day_of_the_week = day
    morning.edition.save(day.to_s + '-morning')

    puts '- ' + day.to_s + ' afternoon'
    afternoon = Bullish.afternoon_edition
    afternoon.edition.day_of_the_week = day 
    afternoon.edition.save(day.to_s + '-afternoon')
  end
end

def send_email(bullish, day = nil)
  bullish.edition.day_of_the_week = day if day

  bullish.post
end

def preview_email(bullish, day = nil)
  bullish.edition.day_of_the_week = day if day

  bullish.save
end
