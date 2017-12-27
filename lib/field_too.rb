class FieldToo
  attr_accessor :top, :left, :width, :height, :name, :text,
                :font_size, :locked, :hide_border, :transparent

  def initialize attrs = {}
    @top = attrs['top']
    @left = attrs['left']
    @width = attrs['width']
    @height = attrs['height']
    @name = attrs['name']
    @text = attrs['text']
    @locked = attrs['locked']
    @font_size = attrs['font_size']
    @hide_border = attrs['hide_border']
    @transparent = attrs['transparent']
  end

  def method_sym
    :cool_field_too
  end

  def opts
    {
      top: top,
      left: left,
      width: width,
      height: height,
      name: name,
      text: text,
      locked: locked,
      font_size: font_size,
      hide_border: hide_border,
      transparent: transparent
    }
  end

  def to_h
    { type: 'field_too' }.merge opts
  end
end
