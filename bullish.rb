# frozen_string_literal: true

require './services/email'
require './services/log'
require './editions/morning'
require './editions/afternoon'
require './editions/free'
require './editions/edition'
require './services/sample'

# buy high sell low
class Bullish
  attr_reader :edition

  def initialize(edition = Editions::Edition.new)
    @edition = edition
  end

  def self.free_edition
    new(Editions::Free.new)
  end

  def self.morning_edition
    new(Editions::Morning.new).tap do |e|
      Services::Sample.new.upload(e.edition.content)
    end
  end

  def self.afternoon_edition
    new(Editions::Afternoon.new).tap do |e|
      Services::Sample.new.upload(e.edition.content)
    end
  end

  # send email to subscribers
  # retry 3 times when fail
  def post
    retries ||= 0

    Services::Email.new(edition).post if edition.send?
  rescue StandardError => e
    retries += 1
    retry if retries < 3

    Services::Log.error(e.message)
    raise e
  end

  def save
    @edition.save
  end
end
