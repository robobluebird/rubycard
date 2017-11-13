class Button
  attr_accessor :top, :left, :width, :height, :text, :font_size, :button_type, :code

  def initialize(attrs = {})
    @top = attrs['top']
    @left = attrs['left']
    @width = attrs['width']
    @height = attrs['height']
    @text = attrs['text']
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
      text: text,
      font_size: font_size,
      button_type: button_type,
      code: code
    }
  end
end
