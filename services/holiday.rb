# frozen_string_literal: true

require 'date'
require 'active_support/all'

# https://www.nyse.com/markets/hours-calendars
class Holiday
  DATES = %w[
    Jan-01-2020
    Jan-20-2020
    Feb-17-2020
    Apr-10-2020
    May-25-2020
    Jul-03-2020
    Sep-07-2020
    Nov-26-2020
    Dec-25-2020
    Jan-01-2021
    Jan-18-2021
    Feb-15-2021
    Apr-02-2021
    May-31-2021
    Jul-05-2021
    Sep-06-2021
    Nov-25-2021
    Dec-24-2021
    Jan-17-2022
    Feb-21-2022
    Apr-15-2022
    May-30-2022
    Jul-04-2022
    Sep-05-2022
    Nov-24-2022
    Dec-26-2022
  ].freeze

  def self.today?(date = current_date)
    date = date.strftime('%b-%d-%Y')

    DATES.include? date
  end

  def self.current_date
    DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)')
  end
end
