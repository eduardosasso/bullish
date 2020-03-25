# frozen_string_literal: true

require 'net/http'
require 'dotenv'
require 'date'

# prepare and send emails using sendgrid
class Email
  attr_reader :subject, :body

  def initialize(subject, body)
    Dotenv.load

    @subject = subject
    @body = body
  end

  def post(send_to_all = true)
    update(subject, body)

    path = [
      '/marketing',
      'singlesends',
      identification,
      'schedule'
    ].join('/')

    data = { 'send_at': 'now' }

    data['filter'] = { 'list_ids': [ENV['TEST_USER_ID']] } unless send_to_all

    request(path, data, 'PUT')
  end

  def update(subject, body)
    path = [
      '/templates',
      ENV['TEMPLATE_ID'],
      'versions',
      ENV['TEMPLATE_VERSION_ID']
    ].join('/')

    data = {
      "subject": subject,
      "html_content": body
    }

    request(path, data, 'PATCH')
  end

  def identification
    path = '/marketing/singlesends'

    data = {
      'name': 'Bullish for ' + Date.today.strftime("%A"),
      'template_id': ENV['TEMPLATE_ID'],
      'sender_id': ENV['SENDER_ID'].to_i,
      'filter': { 'send_to_all': true },
      'suppression_group_id': ENV['UNSUBSCRIBE_GROUP_ID'].to_i
    }

    http = request(path, data, 'POST')

    # returns new singlesend id
    JSON.parse(http.read_body).dig('id')
  end

  def uri
    URI(ENV['SENDGRID_API'])
  end

  def http
    Net::HTTP.new(uri.host, uri.port).tap do |h|
      h.use_ssl = true
    end
  end

  def headers
    {
      'Authorization': 'Bearer ' + ENV['SENDGRID_API_KEY'],
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    }
  end

  def request(path, data = nil, method = 'GET')
    data = data.to_json if data
    path = ENV['API_VERSION'] + path

    http.send_request(method, path, data, headers).tap do |res|
      unless %w[200 201].include?(res.code)
        raise "#{res.code} - #{path} - #{res.body}"
      end
    end
  end
end
