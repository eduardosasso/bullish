# frozen_string_literal: true

require './services/ticker'
require './templates/template'
require './services/holiday'
require './services/config'

# types of email
module Editions
  class Edition
    MINUS = '-'

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
