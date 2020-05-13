require 'mustache'

class Element
  MINUS = '-'

  COLOR = {
    red: '#d63447',
    green: '#21bf73'
  }.freeze

  Item = Struct.new(
    :title,
    :subtitle,
    :undertitle,
    :value,
    :color, #set automatically
    keyword_init: true
  )

  Stats = Struct.new(
    :title,
    :subtitle,
    :undertitle,
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

  def self.html
    load(:html)
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

  def self.title(data = Title)
    render(:title, data)
  end

  def self.item(data = Item)
    data.color = color(data.value)

    render(:item, data)
  end

  def self.stats(data = Stats)
    data._1D_color = color(data._1D)
    data._5D_color = color(data._5D)
    data._1M_color = color(data._1M)
    data._3M_color = color(data._3M)
    data._6M_color = color(data._6M)
    data._1Y_color = color(data._1Y)
    data._5Y_color = color(data._5Y)
    data._10Y_color = color(data._10Y)

    render(:stats, data)
  end

  def self.render(name, data)
    content = load(name)

    Mustache.render(content, data.to_h)
  end

  def self.load(name)
    name = "templates/html/#{name}.html"

    File.read(name)
  end

  def self.color(value)
    value.to_s.start_with?(MINUS) ? COLOR[:red] : COLOR[:green]
  end
end
