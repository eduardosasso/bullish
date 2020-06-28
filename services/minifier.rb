# frozen_string_literal: true

require 'htmlcompressor'

module Services
  class Minifier
    def self.html(content)
      HtmlCompressor::Compressor.new.compress(content)
    end
  end
end
