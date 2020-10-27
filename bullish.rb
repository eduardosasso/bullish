# frozen_string_literal: true

require './services/email'
require './services/log'
require './editions/morning'
require './editions/afternoon'
require './editions/free'
require './editions/edition'
require './services/sample'
require './services/archive'
require './services/log'
require './services/config'

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
    new(Editions::Morning.new)
  end

  def self.afternoon_edition
    new(Editions::Afternoon.new)
  end

  def archive
    return unless edition.premium?

    subject = edition.subject
    content = edition.content

    Services::Sample.new.upload(content)
    Services::Archive.new.upload(subject, content)
  rescue StandardError => e
    Services::Log.error(e.message)
  end

  # send email to subscribers
  # retry 3 times when fail
  def post
    return unless edition.send?

    retries ||= 0

    Services::Email.new(edition).post && archive
  rescue StandardError => e
    retries += 1
    retry if retries < 3

    Services::Log.error(e.message)
    raise e
  end

  def save
    edition.save
  end

  def save_template
    edition.save_template
  end
end
