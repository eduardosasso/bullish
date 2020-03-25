# frozen_string_literal: true

require 'minitest/autorun'
require './template'

class TemplateTest < Minitest::Test
  def test_compile
    data = { sp500_f: 100 }
    template = Template.new(data).compile

    assert(!template.include?(data.keys.first.to_s))
  end
end
