# frozen_string_literal: true

require 'nokogiri'

module Services
  class Popup
    def initialize(html)
      @html = html
    end

    def inject
      popup_js = File.read('templates/html/popup.html')

      head = parser.at('head')
      head << popup_js

      parser.to_html
    end

    private

    def parser
      @parser ||= Nokogiri::HTML.parse(@html)
    end
  end
end
