# frozen_string_literal: true

require 'mustache'
require './templates/element'
require './services/mjml'
require './services/minifier'
require 'date'

module Templates
  class Template
    attr_accessor :preheader, :premium

    def initialize(elements = [Element.title])
      @elements = elements
      @preheader = nil
      @premium = false
    end

    def body
      [
        Element.header(@premium),
        Element.spacer('15px'),
        sponsor,
        Element.divider,
        @elements,
        Element.divider,
        sponsor,
        Element.footer(@premium)
      ].flatten.compact.join(' ')
    end

    def compile
      data = Element::Html.new(
        preheader: @preheader,
        body: body
      )

      Element.html(data)
    end

    def sponsor
      return if @premium

      labels = [
        '<a href="https://www.startengine.com/nanovms" style="color:#FFF"><b><u>Angel Invest in this Silicon Valley Cyber Company</u></b></a><br/> They have revenue, patents raised 2.4M from Bloomberg Beta & Initialized Capital. <p><a href="https://www.startengine.com/nanovms" style="color: #FFF">Click here to learn more</a></p>'
      ]

      Element.sponsor(labels.sample)
    end

    def to_html
      mjml = compile

      Services::Mjml.new(mjml).to_html
    end

    def self.edition(edition)
      all_elements = edition.title + edition.elements

      new(all_elements).tap do |t|
        t.preheader = edition.preheader
        t.premium = edition.premium?
      end
    end
  end
end
