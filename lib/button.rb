class Button
  attr_accessor :top, :left, :width, :height, :name, :title, :font_size, :button_type, :script

  def initialize(attrs = {})
    @top = attrs['top']
    @left = attrs['left']
    @width = attrs['width']
    @height = attrs['height']
    @name = attrs['name']
    @title = attrs['title']
    @font_size = attrs['font_size']
    @button_type = attrs['button_type']
    @script = attrs['script']
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
      name: name,
      title: title,
      font_size: font_size,
      button_type: button_type,
      script: script
    }
  end

  def to_h
    { type: 'button' }.merge opts
  end
end
