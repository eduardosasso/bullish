# frozen_string_literal: true

require 'nokogiri'
require 'cgi'

# replaces keys in template with values
class Template
  attr_reader :data

  COLOR = {
    red: '#d63447',
    green: '#21bf73'
  }.freeze

  # convention:
  # hash with {symbol_{period}: value}
  # {sp500_f: -10%}
  # {nasdaq_1M: 20%}
  def initialize(data = {})
    @data = data
  end

  def html
    # save from sendgrid on change
    file = File.read('template.html')

    Nokogiri::HTML(file)
  end

  def compile
    result = html.tap do |doc|
      data.each do |index, value|
        next unless value

        # look for string in html like nasdaq_f, sp500_1M etc
        field = ":contains('#{index}'):not(:has(:contains('#{index}')))"
        doc.at(field).tap do |tag|
          next unless tag

          tag.content = value

          tag.parent.attributes['style'].tap do |css|
            if css
              css.content = css.content.gsub(COLOR[:red], color(value))
              css.content = css.content.gsub(COLOR[:green], color(value))
            end
          end
        end
      end
    end.to_s

    CGI.unescape(result)
  end

  def color(value)
    value.to_s.start_with?(Bullish::MINUS) ? COLOR[:red] : COLOR[:green]
  end
end
