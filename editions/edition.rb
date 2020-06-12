# frozen_string_literal: true

require './services/ticker'
require './templates/template'
require './services/holiday'
require './services/config'

# types of email
module Editions
  class Edition
    attr_writer :day_of_the_week

    MINUS = '-'

    DAY_ELEMENTS = {
      monday: :monday_elements,
      tuesday: :tuesday_elements,
      wednesday: :wednesday_elements,
      thursday: :thursday_elements,
      friday: :friday_elements
    }.freeze

    def subject
      raise 'should override subject'
    end

    def preheader
      raise 'should override preheader'
    end

    def content
      Templates::Template.new(elements, preheader).to_html
    end

    def elements
      raise 'override and return an Array of Element'
    end

    # override for editions like weekend
    def send?
      # TODO: rename to better name
      !Services::Holiday.today?
    end

    def monday_elements
      []
    end

    def tuesday_elements
      []
    end

    def wednesday_elements
      []
    end

    def thursday_elements
      []
    end

    def friday_elements
      []
    end

    def todays_elements(day = day_of_the_week)
      method = DAY_ELEMENTS[day.to_sym]
      send(method)
    end

    def all_time_high
      # Services::Tiker.sp500.peak
    end

    def day_of_the_week
      @day_of_the_week ||= Services::Config.date_time_et.strftime('%A').downcase
    end

    def formatted_date
      Services::Config.date_time_et.strftime('%B %d, %Y')
    end

    def formatted_time
      Services::Config.date_time_et.strftime('%I:%M%p ET')
    end

    def subscribers_group_id
      raise 'override with subscribers group from mailerlite'
    end

    # save as html file for testing
    def save
      filename = 'tmp/' + subject + '.html'

      File.open(filename, 'w+') do |f|
        f.write(content)
      end
    end
  end
end
