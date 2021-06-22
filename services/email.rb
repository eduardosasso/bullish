# frozen_string_literal: true

require 'net/http'
require 'faraday'
require 'json'
require './services/config'

# https://developers.mailerlite.com/reference
# prepare and send emails using mailerlite
module Services
  class Email
    attr_reader :subject, :body, :group

    def initialize(edition = Edition)
      @subject = edition.subject
      @body = edition.content
      @group = edition.subscribers_group_id
    end

    def post
      id = create_campaign

      update_campaign(id)
      send_campaign(id)
    end

    def create_campaign
      body = {
        name: subject,
        subject: subject,
        type: 'regular',
        groups: group
      }

      if Services::Config.test?
        body[:name] += ' **TEST**'
        body[:subject] += ' **TEST**'
        body[:groups] = Services::Config.test_group
      end

      post_request('/campaigns', body).dig('id')
    end

    def update_campaign(campaign_id)
      content = {
        html: body,
        plain: '{$unsubscribe} {$url}'
      }

      put_request("/campaigns/#{campaign_id}/content", content)
    end

    def send_campaign(campaign_id)
      post_request("campaigns/#{campaign_id}/actions/send")
    end

    def request(path, data = {}, method = 'get')
      path = File.join('/api/v2/', path)

      response = mailerlite.send(method, path) do |r|
        r.body = data.to_json
      end

      raise "#{response.status} - #{path} - #{response.body}" unless response.status == 200

      JSON.parse(response.body)
    end

    def mailerlite
      Faraday.new(
        url: 'https://api.mailerlite.com/',
        headers: {
          'Content-Type': 'application/json',
          'X-MailerLite-ApiKey': ENV['MAILERLITE_API_KEY']
        }
      )
    end

    def get_request(path, data = {})
      request(path, data, 'get')
    end

    def post_request(path, data = {})
      request(path, data, 'post')
    end

    def put_request(path, data = {})
      request(path, data, 'put')
    end
  end
end
