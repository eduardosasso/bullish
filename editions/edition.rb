# frozen_string_literal: true

require './services/ticker'
require './templates/template'
require './services/holiday'
require './services/config'
require './services/trending'
require './services/crypto'
require './services/world'
require './services/log'
require './editions/widgets'

module Editions
  class Edition
    include Widgets

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
      @content ||= template.to_html
    end

    def template
      @template ||= Templates::Template.edition(self)
    end

    def elements
      raise 'override and return an Array of Element'
    end

    def subscribers_group_id
      raise 'override with subscribers group from mailerlite'
    end

    def send?
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

    def sp500_performance
      stats(ticker(:sp500))
    end

    def nasdaq_performance
      stats(ticker(:nasdaq))
    end

    def dowjones_performance
      stats(ticker(:dowjones))
    end

    def bitcoin_performance
      stats(ticker(:bitcoin))
    end

    def gold_performance
      stats(ticker(:gold))
    rescue StandardError => e
      Services::Log.error(e.message)
      []
    end

    def russell2000_performance
      stats(ticker(:russell2000))
    end

    def treasury_performance
      stats(ticker(:treasury))
    rescue StandardError => e
      Services::Log.error(e.message)
      []
    end

    def ticker(key)
      Services::Ticker.send(key)
    end

    def day_of_the_week
      @day_of_the_week ||= Services::Config.date_time_et.strftime('%A').downcase
    end

    def formatted_date
      Services::Config.formatted_date
    end

    def formatted_time
      Services::Config.formatted_time
    end

    def premium?
      subscribers_group_id == Services::Config.premium_group_id
    end

    # save as html file for testing
    def save(data: content, name: subject + '.html')
      filename = 'tmp/' + name

      File.open(filename, 'w+') do |f|
        f.write(data)
      end
    end

    def save_template
      name = 'preview_' + DateTime.now.strftime('%m_%d_%Y') + '.mjml'

      save(data: template.compile, name: name)
    end
  end
end
