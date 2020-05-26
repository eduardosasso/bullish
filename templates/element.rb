# frozen_string_literal: true

require 'ostruct'
require 'mustache'

module Templates
  class Element
    MINUS = '-'

    COLOR = {
      red: '#d63447',
      green: '#21bf73'
    }.freeze

    Html = Struct.new(
      :preheader,
      :body,
      keyword_init: true
    )

    Item = Struct.new(
      :title,
      :subtitle,
      :symbol,
      :value,
      :color, # set automatically
      keyword_init: true
    )

    Stats = Struct.new(
      :title,
      :subtitle,
      :symbol,
      :_1D,
      :_5D,
      :_1M,
      :_3M,
      :_6M,
      :_1Y,
      :_5Y,
      :_10Y,
      # set automatically
      :_1D_color,
      :_5D_color,
      :_1M_color,
      :_3M_color,
      :_6M_color,
      :_1Y_color,
      :_5Y_color,
      :_10Y_color,
      keyword_init: true
    )

    Title = Struct.new(
      :title,
      :subtitle,
      :undertitle,
      keyword_init: true
    )

    def self.html(html_struct = nil)
      render(:html, html_struct)
    end

    def self.header
      load(:header)
    end

    def self.footer
      load(:footer)
    end

    def self.divider
      load(:divider)
    end

    def self.spacer(height = '10px')
      height_struct = OpenStruct.new(height: height)

      render(:spacer, height_struct)
    end

    def self.title(title_struct = nil)
      render(:title, title_struct)
    end

    def self.item(item_struct = nil)
      item_struct.color = color(item_struct.value) if item_struct

      render(:item, item_struct)
    end

    def self.stats(stats_struct = nil)
      if stats_struct
        stats_struct._1D_color = color(stats_struct._1D)
        stats_struct._5D_color = color(stats_struct._5D)
        stats_struct._1M_color = color(stats_struct._1M)
        stats_struct._3M_color = color(stats_struct._3M)
        stats_struct._6M_color = color(stats_struct._6M)
        stats_struct._1Y_color = color(stats_struct._1Y)
        stats_struct._5Y_color = color(stats_struct._5Y)
        stats_struct._10Y_color = color(stats_struct._10Y)
      end

      render(:stats, stats_struct)
    end

    def self.render(name, data)
      content = load(name)
      data = data.send(:to_h) || {}

      data.any? ? Mustache.render(content, data) : content
    end

    def self.load(name)
      name = "templates/html/#{name}.html"

      File.read(name)
    end

    def self.color(value)
      value.to_s.start_with?(MINUS) ? COLOR[:red] : COLOR[:green]
    end
  end
end
