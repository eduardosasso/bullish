# frozen_string_literal: true

require './email'
require './premarket/premarket_edition'
require './closing/closing_edition'
require './edition'
require 'raven'

# buy high sell low
class Bullish
  attr_reader :edition

  def initialize(edition = Edition.new)
    @edition = edition
  end

  def self.premarket_edition
    new(PremarketEdition.new)
  end

  def self.closing_edition
    new(ClosingEdition.new)
  end

  # send email to subscribers
  # retry 3 times when fail
  def post
    retries ||= 0

    Email.new(edition).post if edition.send?
  rescue StandardError => e
    retries += 1
    retry if retries < 3

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
