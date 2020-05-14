# frozen_string_literal: true

require 'minitest/autorun'
require './templates/template'
require './templates/element'

module Templates
  class TemplateTest < Minitest::Test
    def test_compile
      custom_element = '<h1>{{title}}</h1>'

      template = Templates::Template.new([custom_element]).compile

      assert_match(/{{title}}/, template)

      template = Templates::Template.new([custom_element]).compile({ title: 'ABCDEF' })

      assert_match(/ABCDEF/, template)
    end

    def test_compile_wrapper
      Templates::Element.stub(:html, 'begin {{body}} end') do
        Templates::Element.stub(:header, 'header') do
          Templates::Element.stub(:footer, 'footer') do
            custom_element = ' body '

            template = Templates::Template.new([custom_element]).compile
            assert_equal('begin header  body  footer end', template)
          end
        end
      end
    end
  end
end
