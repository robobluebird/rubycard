class Button
  attr_accessor :top, :left, :width, :height, :title, :font_size, :button_type, :code

  def initialize(attrs = {})
    @top = attrs['top']
    @left = attrs['left']
    @width = attrs['width']
    @height = attrs['height']
    @title = attrs['title']
    @font_size = attrs['font_size']
    @button_type = attrs['button_type']
    @code = attrs['code']
  end

  def method_sym
    :cool_button
  end

  def opts
    {
      top: top,
      left: left,
      width: width,
      height: height,
      title: title,
      font_size: font_size,
      button_type: button_type,
      code: code
    }
  end

  def to_h
    { type: 'button' }.merge opts
  end
end
