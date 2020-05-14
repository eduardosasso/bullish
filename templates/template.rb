# frozen_string_literal: true

require 'mustache'
require './templates/element'
require 'date'

module Templates
  class Template
    def initialize(elements = [Element.title])
      @body = [
        Element.header,
        elements,
        Element.footer
      ].flatten.join(' ')
    end

    def compile(data = {})
      @body = Mustache.render(@body, data) unless data.empty?

      Mustache.render(Element.html, { body: @body })
    end

    def self.save(content, name = preview_name)
      filename = 'tmp/' + name + '.html'

      File.open(filename, 'w+') do |f|
        f.write(content)
      end

      'Preview saved in ' + filename
    end

    def self.preview_name
      'preview_' + DateTime.now.strftime('%m_%d_%Y')
    end
  end
end
