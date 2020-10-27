# frozen_string_literal: true

require './test/test_helper'
require './templates/template'
require './templates/element'

module Templates
  class TemplateTest < Minitest::Test
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
            <mj-attributes>
              <mj-all font-family=\"Helvetica, Arial\"/>
            </mj-attributes>

            <mj-preview></mj-preview>
          </mj-head>
          <mj-body background-color='#1b262c' width=\"100%\">
            header     body   footer
          </mj-body>
        </mjml>
      MJML

      # Templates::Element.stub(:html, 'begin {{body}} end') do
      Templates::Element.stub(:divider, '') do
        Templates::Element.stub(:spacer, '') do
          Templates::Element.stub(:sponsor, '') do
            Templates::Element.stub(:header, 'header') do
              Templates::Element.stub(:footer, 'footer') do
                custom_element = ' body '

                template = Templates::Template.new([custom_element]).compile
                assert_equal(result, template)
              end
            end
          end
        end
      end
    end
  end
end
