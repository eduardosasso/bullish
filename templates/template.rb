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
        '<a href="https://www.moneymachinenewsletter.com/lp/fivestocks?utm_source=newsletter&utm_medium=email&utm_campaign=Q1_2022_newsletter&utm_content=fivestocks_bullishStockMarket" style="color:#FFF"><b><u>5 Stocks With The Opportunity For A Massive Move This Week</u></b></a><br/><a href="https://www.moneymachinenewsletter.com/lp/fivestocks?utm_source=newsletter&utm_medium=email&utm_campaign=Q1_2022_newsletter&utm_content=fivestocks_bullishStockMarket" style="color:#FFF">Money Machine Newsletter</a> delivers these stock ideas daily to your inbox.',
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
