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

    Premium = Struct.new(
      :premium,
      keyword_init: true
    )

    Item = Struct.new(
      :title,
      :subtitle,
      :undertitle,
      :symbol,
      :value,
      :color, # set automatically
      keyword_init: true
    )

    Group = Struct.new(
      :title1,
      :subtitle1,
      :symbol1,
      :value1,
      :color1, # set automatically
      :title2,
      :subtitle2,
      :symbol2,
      :value2,
      :color2, # set automatically
      keyword_init: true
    )

    Stats = Struct.new(
      :title,
      :subtitle,
      :symbol,
      :news,
      :news_url,
      :news_source,
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

    def self.header(premium = false)
      render(:header, Premium.new(premium: premium))
    end

    def self.footer(premium = false)
      render(:footer, Premium.new(premium: premium))
    end

    def self.divider
      load(:divider)
    end

    def self.sponsor(label = 'Your Ad here')
      render(:sponsor, OpenStruct.new(label: label))
    end

    def self.subscribe_premium(headline, label = 'Subscribe now')
      subscribe_struct = OpenStruct.new(label: label, headline: headline)

      render(:premium, subscribe_struct)
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

    def self.group(group_struct = nil)
      if group_struct
        group_struct.color1 = color(group_struct.value1)
        group_struct.color2 = color(group_struct.value2)
      end

      render(:group, group_struct)
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
