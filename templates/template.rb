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
        # sponsor,
        Element.divider,
        @elements,
        Element.divider,
        # sponsor,
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
        '<a href="https://www.m1finance.com/?utm_source=bullishnewsletter&utm_medium=influencer&utm_campaign=content-influencer&utm_term=newsletter&utm_content=a1-general-202107" style="color:#FFF"><b><u>Invest, borrow, and spend with M1, The Finance Super App™</u></b></a><br/>Join the investors who are automating their money with M1. Start today and get $30. <br/>Terms and conditions apply.<p><a href="https://www.m1finance.com/?utm_source=bullishnewsletter&utm_medium=influencer&utm_campaign=content-influencer&utm_term=newsletter&utm_content=a1-general-202107" style="color: #FFF">Click here to learn more →</a></p>'
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
