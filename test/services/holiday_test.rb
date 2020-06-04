# frozen_string_literal: true

require './test/test_helper'
require './services/holiday'
require 'minitest/mock'

module Services
  class HolidayTest < Minitest::Test
    def test_holiday
      holiday = Services::Holiday::DATES.sample

      date = Date.parse(holiday)

      assert(Services::Holiday.today?(date))
    end

    def test_not_holiday
      refute(Services::Holiday.today?)
    end

    # break to make sure I update the
    # holiday list every year
    def test_holidays_year
      years = Services::Holiday::DATES.map do |d|
        Date.parse(d).strftime('%Y')
      end.uniq

      current_year = Services::Holiday.current_date.strftime('%Y')

      assert(years.include?(current_year))
    end
  end
end
