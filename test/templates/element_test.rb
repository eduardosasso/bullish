# frozen_string_literal: true

require 'minitest/autorun'
require './templates/element'

module Templates
  class ElementTest < Minitest::Test
    def test_header
      assert(Templates::Element.header)
    end

    def test_footer
      assert(Templates::Element.footer)
    end

    def test_divider
      assert(Templates::Element.divider)
    end

    def test_title
      data = Templates::Element::Title.new(
        title: 'IBM',
        subtitle: 'PC',
        undertitle: 'Nothing'
      )

      Templates::Element.stub(:load, 'title: {{title}} subtitle: {{subtitle}}') do
        assert_equal('title: IBM subtitle: PC', Templates::Element.title(data))
      end
    end

    def test_item
      data = Templates::Element::Item.new(
        title: 'IBM',
        value: '103.22'
      )

      Templates::Element.stub(:load, '{{color}}') do
        assert_equal(Templates::Element::COLOR[:green], Templates::Element.item(data))

        data.value = '-33'
        assert_equal(Templates::Element::COLOR[:red], Templates::Element.item(data))
      end
    end

    def test_stats
      data = Templates::Element::Stats.new(
        title: 'IBM',
        _1D: '103.22%',
        _5D: '-10.22%',
        _1M: '22%',
        _3M: '-44%',
        _6M: '200.65%',
        _1Y: '-87.323%',
        _5Y: '12%',
        _10Y: '-42%'
      )

      colors = '{{_1D_color}} {{_5D_color}} {{_1M_color}} {{_3M_color}} {{_6M_color}} {{_1Y_color}} {{_5Y_color}} {{_10Y_color}}'

      Templates::Element.stub(:load, colors) do
        green = Templates::Element::COLOR[:green]
        red = Templates::Element::COLOR[:red]

        result = "#{green} #{red} #{green} #{red} #{green} #{red} #{green} #{red}"

        assert_equal(result, Templates::Element.stats(data))
      end
    end
  end
end
