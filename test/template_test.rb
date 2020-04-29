# frozen_string_literal: true

require 'minitest/autorun'
require './template'

class TemplateTest < Minitest::Test
  def test_compile
    file = File.read('premarket/template.html')
    data = { sp500_f: 100 }

    template = Template.new(file).compile(data)

    assert(!template.include?(data.keys.first.to_s))
  end
end
