# frozen_string_literal: true

require 'minitest/autorun'
require './templates/template'
require './templates/element'

module Templates
  class TemplateTest < Minitest::Test
    def test_preview
      content = Templates::Template.new(
        [
          Templates::Element.divider,
          Templates::Element.title,
          Templates::Element.item,
          Templates::Element.item
        ]
      ).compile

      Templates::Template.save(content)

      file = File.open("./tmp/#{Templates::Template.preview_name}.html")

      assert(file)

      File.delete(file)
    end

    def test_compile
      template = Templates::Template.new([Templates::Element.title]).compile

      assert_match(/{{title}}/, template)

      data = Templates::Element::Title.new(title: 'Nasdaq')
      template = Templates::Template.new([Templates::Element.title(data)]).compile

      assert_match(/Nasdaq/, template)
    end

    def test_to_html
      assert_match(/<!doctype html>/, Templates::Template.new.to_html)
    end

    def test_compile_wrapper
      result = <<~MJML
        <mjml>
          <mj-head>
            <mj-preview></mj-preview>
          </mj-head>
          <mj-body background-color='#1b262c' width=\"100%\">
            header   body   footer
          </mj-body>
        </mjml>
      MJML

      # Templates::Element.stub(:html, 'begin {{body}} end') do
      Templates::Element.stub(:divider, '') do
        Templates::Element.stub(:header, 'header') do
          Templates::Element.stub(:footer, 'footer') do
            custom_element = ' body '

            template = Templates::Template.new([custom_element]).compile
            assert_equal(result, template)
          end
        end
        # end
      end
    end
  end
end
