class Image
  attr_accessor :top, :left, :width, :height, :ratio,
                :ratio_direction, :name, :path, :script

  def initialize(attrs = {})
    @top = attrs['top']
    @left = attrs['left']
    @width = attrs['width']
    @height = attrs['height']
    @ratio = attrs['ratio']
    @ratio_direction = attrs['ratio_direction']
    @name = attrs['name']
    @path = attrs['path']
    @script = attrs['script']
  end

  def method_sym
    :cool_image
  end

  def opts
    {
      top: top,
      left: left,
      width: width,
      height: height,
      ratio: ratio,
      ratio_direction: ratio_direction,
      name: name,
      path: path,
      script: script
    }
  end

  def to_h
    { type: 'image' }.merge opts
  end
end
