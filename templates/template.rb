# frozen_string_literal: true

require 'mustache'
require './templates/element'
require './services/mjml'
require './services/minifier'
require 'date'

module Templates
  class Template
    def initialize(elements = [Element.title], preheader = nil)
      @preheader = preheader

      @body = [
        Element.header,
        Element.spacer('15px'),
        Element.divider,
        elements,
        Element.divider,
        Element.footer
      ].flatten.join(' ')
    end

    def compile
      data = Element::Html.new(
        preheader: @preheader,
        body: @body
      )

      Element.html(data)
    end

    def to_html
      mjml = compile

      html = Services::Mjml.new(mjml).to_html

      Services::Minifier.html(html)
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
