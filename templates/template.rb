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
        '<a href="https://click.letterwell.co/163501244653780459261" style="color:#FFF"><b><u>Morning Brew</u></b></a><br/>Find out why over 3 million people read <a href="https://click.letterwell.co/163501244653780459261" style="color: #FFF">Morning Brew.</a><br/>It is free to subscribe!</a>',
        '<a href="https://click.letterwell.co/163501244653780459261" style="color:#FFF"><b><u>Morning Brew</u></b></a><br/><a href="https://click.letterwell.co/163501244653780459261" style="color:#FFF">Morning Brew</a> delivers the top business stories to over 3 million readers each morning.<br/><a href="https://click.letterwell.co/163501244653780459261" style="color: #FFF">Subscribe now!</a>',
        '<a href="https://click.letterwell.co/163501244613575774209" style="color:#FFF"><b><u>Dollar Flight Club</u></b></a><br/>An exclusive members-only club that sends you email alerts when they find flights up to 90% off leaving your home airport.'
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
