# frozen_string_literal: true

require 'net/http'
require 'nokogiri'
require 'dotenv'
require 'json'
require 'raven'
require 'cgi'

class Bullish
  attr_reader :fields

  COLOR = {
    red: '#d63447',
    green: '#21bf73'
  }.freeze

  FUTURES = {
    'Future-US-NQ00' => 'f_nasdaq',
    'Future-US-ES00' => 'f_sp500',
    'Future-US-YM00' => 'f_dowjones'
  }.freeze

  def initialize
    Dotenv.load

    @fields = {
      subject: nil,
      # TODO: add ET time before open markets
      f_date: Time.now.strftime('%B %d, %Y'),
      f_sp500: nil,
      f_nasdaq: nil,
      f_dowjones: nil
    }
  end

  def html_template
    # save from sendgrid on change
    File.read('template.html')
  end

  def prepare_template
    html = Nokogiri::HTML(html_template).tap do |doc|
      @fields.each do |index, value|
        next unless value

        field = ":contains('#{index}'):not(:has(:contains('#{index}')))"
        doc.at(field).tap do |tag|
          next unless tag

          tag.content = value

          tag.parent.attributes['style'].tap do |css|
            css.content = css.content.gsub(COLOR[:red], color(value))
            css.content = css.content.gsub(COLOR[:green], color(value))
          end
        end
      end
    end.to_s

    CGI.unescape(html)
  end

  def craft_subject
    @fields[:subject] = 'test subject'
  end

  def email_subscribers(test = ENV['TEST'])
    fetch_futures
    fetch_market

    subject = craft_subject
    body = prepare_template

    sendgrid_update_template(subject, body)

    send_to_all = test ? false : true
    sendgrid_trigger_single_send(send_to_all)
  end

  def color(value)
    negative = '-'

    value.to_s.start_with?(negative) ? COLOR[:red] : COLOR[:green]
  end

  def fetch_futures
    uri = URI ENV['MARKET_API']

    response = Net::HTTP.get(uri)

    JSON.parse(response)['InstrumentResponses'].each do |r|
      next unless FUTURES.keys.include?(r['RequestId'])

      key = FUTURES[r['RequestId']].to_sym
      value = r['Matches'].first['CompositeTrading']['ChangePercent']

      @fields[key] = value.to_f.round(2).to_s + '%'
    end
  end

  def fetch_market; end

  def sendgrid_request(path, data = nil, method = 'GET')
    uri = URI(ENV['SENDGRID_API'])

    headers = {
      'Authorization' => 'Bearer ' + ENV['SENDGRID_API_KEY'],
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    data = data.to_json if data

    http.send_request(method, ENV['API_VERSION'] + path, data, headers).tap do |res|
      unless %w[200 201].include? res.code
        message = res.code + ' - ' + path + ' - ' + res.body.to_s

        Raven.capture_message(message)

        raise Exception, message
      end
    end
  end

  def sendgrid_update_template(subject, body)
    path = "/templates/#{ENV['TEMPLATE_ID']}/versions/#{ENV['TEMPLATE_VERSION_ID']}"

    data = {
      "subject": subject,
      "html_content": body
    }

    sendgrid_request(path, data, 'PATCH')
  end

  def sendgrid_new_single_send
    path = '/marketing/singlesends'

    data = {
      'name': 'Bullish for ' + @fields[:f_date],
      'template_id': ENV['TEMPLATE_ID'],
      'sender_id': ENV['SENDER_ID'].to_i,
      'filter': { 'send_to_all': true },
      'suppression_group_id': ENV['UNSUBSCRIBE_GROUP_ID'].to_i
    }

    http = sendgrid_request(path, data, 'POST')

    # returns new singlesend id
    JSON.parse(http.read_body)['id']
  end

  def sendgrid_trigger_single_send(send_to_all = true)
    id = sendgrid_new_single_send

    path = "/marketing/singlesends/#{id}/schedule"

    data = { 'send_at': 'now' }

    data['filter'] = { 'list_ids': [ENV['TEST_USER_ID']] } unless send_to_all

    sendgrid_request(path, data, 'PUT')
  end
end
