# frozen_string_literal: true

require 'minitest/autorun'
require './bullish'
require 'minitest/mock'
require './holiday'

class BullishTest < Minitest::Test
  def test_post_retry
    email = MiniTest::Mock.new
    email.expect(:post, 'first try') { raise 'first try' }
    email.expect(:post, nil) { raise 'second try' }
    email.expect(:post, 'third try')

    edition = MiniTest::Mock.new
    edition.expect(:subject, 'subject')
    edition.expect(:subject, 'subject1')
    edition.expect(:subject, 'subject2')

    edition.expect(:content, 'content')
    edition.expect(:content, 'content1')
    edition.expect(:content, 'content2')

    edition.expect(:send?, true)
    edition.expect(:send?, true)
    edition.expect(:send?, true)

    Email.stub(:new, email) do
      Edition.stub(:new, edition) do
        assert_equal('third try', Bullish.new.post)
      end
    end
  end

  def test_dont_post_on_holiday
    holiday = Holiday::DATES.sample
    date = Date.parse(holiday)

    holiday_mock = MiniTest::Mock.new
    holiday_mock.expect(:current_date, date)

    Holiday.stub(:current_date, date) do
      assert_nil(Bullish.new.post)
    end
  end
end
