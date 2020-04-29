# frozen_string_literal: true

require './ticker'
require './template.rb'
require './holiday'

# types of email
class Edition
  MINUS = '-'

  ALIAS = {
    'sp500': 'S&P 500',
    'nasdaq': 'Nasdaq',
    'dowjones': 'Dow Jones'
  }.freeze

  def subject
    raise 'should override subject'
  end

  def preheader
    raise 'should override preheader'
  end

  def content
    Template.new(template).compile(data)
  end

  def data
    raise 'override with using a hash to fill the template'
  end

  # override for editions like weekend
  def send?
    # TODO: rename to better name
    !Holiday.today?
  end

  def template
    raise 'override with File.read html file template'
  end

  # date time in ET where markets operate
  def date_time_et
    DateTime.now.utc.in_time_zone('Eastern Time (US & Canada)')
  end

  # rewrite to conform to template data reqs
  # nasdaq to nasdaq_1D, sp500_3M...
  def indexes
    keys = Ticker::INDEX.keys

    keys.each_with_object({}) do |index, hash|
      Ticker.send(index).full_performance.each do |key, value|
        hash["#{index}_#{key}"] = value.to_s + '%'
      end
    end
  end
end
