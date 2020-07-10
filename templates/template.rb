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
        'Your Ad here',
        'Advertise here',
        'Your business here',
        'Sponsor this space'
      ]

      Element.sponsor(labels.sample)
    end

    def to_html
      mjml = compile

      html = Services::Mjml.new(mjml).to_html

      Services::Minifier.html(html)
    end

    def self.edition(edition)
      new(edition.elements).tap do |t|
        t.preheader = edition.preheader
        t.premium = edition.premium?
      end
    end

    def self.save(content, name = preview_name)
      filename = 'tmp/' + name + '.html'

      File.open(filename, 'w+') do |f|
        f.write(content)
      end
    end

    def self.preview_name
      'preview_' + DateTime.now.strftime('%m_%d_%Y')
    end
  end
end
