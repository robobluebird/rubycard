class Field
  attr_accessor :top, :left, :width, :height, :text, :font_size, :hide_border

  def initialize(attrs = {})
    @top = attrs['top']
    @left = attrs['left']
    @width = attrs['width']
    @height = attrs['height']
    @text = attrs['text']
    @font_size = attrs['font_size']
    @hide_border = attrs['hide_border']
  end

  def method_sym
    :cool_field
  end

  def opts
    {
      top: top,
      left: left,
      width: width,
      height: height,
      text: text,
      font_size: font_size,
      hide_border: hide_border
    }
  end
end
