# frozen_string_literal: true
require 'dotenv'
require 'net/http'
require 'raven'

class Index
  INDEX = {
    sp500: '^GSPC',
    nasdaq: 'NDAQ',
    dowjones: '^DJI'
  }.freeze

  FORMAT = {
    daily: 'TIME_SERIES_DAILY',
    weekly: 'TIME_SERIES_WEEKLY',
    montly: 'TIME_SERIES_MONTHLY'
  }

  def initialize(index)
    Dotenv.load

    @index = index
  end

  def self.sp500
    new(INDEX[:sp500])
  end

  def self.nasdaq
    new(INDEX[:nasdaq])
  end

  def self.dowjones
    new(INDEX[:dowjones])
  end

  def one_day
    request(FORMAT[:daily])
  end

  def one_week; end

  def one_month; end

  def three_months; end

  def six_months; end

  def one_year; end

  def five_years; end

  def ten_years; end

  def request(type)
    p ENV['ALPHA_API']
    uri = URI(ENV['ALPHA_API'])

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    path = [
      '/query',
      'function=' + type,
      'symbol=' + @index,
      'api_key=' + ENV['ALPHA_API_KEY']
    ].join('&')

    http.get(path).tap do |res|
      unless %w[200 201].include? res.code
        message = res.code + ' - ' + path + ' - ' + res.body.to_s

        Raven.capture_message(message)

        raise Exception, message
      end
    end
  end
end
