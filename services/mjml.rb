# frozen_string_literal: true

require 'tempfile'

module Services
  class Mjml
    def initialize(mjml)
      @mjml = mjml
    end

    def to_html
      Tempfile.create do |f|
        f << @mjml

        f.rewind

        return `mjml #{f.path} -s --config.beautify false --config.minify true`
      end
    end
  end
end
