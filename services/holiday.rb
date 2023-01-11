# frozen_string_literal: true

require 'date'
require 'active_support/all'

# https://www.nyse.com/markets/hours-calendars
module Services
  class Holiday
    DATES = %w[
      Jan-16-2023
      Feb-20-2023
      Apr-07-2023
      May-29-2023
      Jun-19-2023
      Jul-04-2023
      Sep-04-2023
      Nov-23-2023
      Dec-25-2023
    ].freeze

    def self.today?(date = current_date)
      date = date.strftime('%b-%d-%Y')

      DATES.include? date
    end

    def self.current_date
      DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)')
    end
  end
end
