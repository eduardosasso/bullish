# frozen_string_literal: true

require 'minitest/autorun'
require './holiday'
require 'minitest/mock'

class HolidayTest < Minitest::Test
  def test_holiday
    holiday = Holiday::DATES.sample

    date = Date.parse(holiday)

    assert(Holiday.today?(date))
  end

  def test_not_holiday
    refute(Holiday.today?)
  end

  # break to make sure I update the
  # holiday list every year
  def test_holidays_year
    years = Holiday::DATES.map do |d|
      Date.parse(d).strftime('%Y')
    end.uniq

    current_year = Holiday.current_date.strftime('%Y')

    assert(years.include?(current_year))
  end
end
