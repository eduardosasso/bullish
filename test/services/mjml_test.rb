# frozen_string_literal: true

require './test/test_helper'
require './services/mjml'

class MjmlTest < Minitest::Test
  def test_to_html
    mjml = <<~MJML
      <mjml>
       <mj-body>
        <mj-section>
         <mj-column>
          <mj-text>Hello World</mj-text>
         </mj-column>
        </mj-section>
       </mj-body>
      </mjml>
    MJML

    html = Services::Mjml.new(mjml).to_html

    assert_match(/<!doctype html>/, html)
    assert_match(/Hello World/, html)
  end
end
