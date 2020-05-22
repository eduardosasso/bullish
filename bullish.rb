# frozen_string_literal: true

require './services/email'
require './editions/morning'
require './editions/afternoon'
require './editions/edition'
require 'raven'

# buy high sell low
class Bullish
  attr_reader :edition

  def initialize(edition = Editions::Edition.new)
    @edition = edition
  end

  def self.morning_edition
    new(Editions::Morning.new)
  end

  def self.afternoon_edition
    new(Editions::Afternoon.new)
  end

  # send email to subscribers
  # retry 3 times when fail
  def post
    retries ||= 0

    Services::Email.new(edition).post if edition.send?
  rescue StandardError => e
    retries += 1
    retry if retries < 3

    # TODO: move to a Error service class
    Raven.capture_message(e.message)

    raise e
  end

  # save as html file for testing
  def save
    filename = 'tmp/' + edition.subject + '.html'

    File.open(filename, 'w+') do |f|
      f.write(edition.content)
    end
  end
end
