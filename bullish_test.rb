# frozen_string_literal: true

require 'minitest/autorun'
require './bullish'

class BullishTest < Minitest::Test
  def setup
    ENV['TEST'] = 'true'
  end

  def test_email_subscribers
    Bullish.new.email_subscribers
    # Bullish.new.sendgrid_new_single_send
  end

  def test_replace
    # html = Bullish.new.replace_values
    # File.write('./template_test.html', html)
  end

  def test_sendgrid_api
    # bull = Bullish.new

    # assert_equal('200', bull.sendgrid_request('/designs').code)
  end

  def test_fetch_futures
    bull = Bullish.new

    bull.fetch_futures

    assert bull.fields[:f_nasdaq]
    assert bull.fields[:f_sp500]
    assert bull.fields[:f_dowjones]
  end
end
