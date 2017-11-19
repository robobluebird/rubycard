class CoolImage < CoolElement
  attr_accessor :path, :script, :ratio, :ratio_direction, :name

  def path
    @image.path
  end

  def style(styles = nil)
    if @ratio && styles
      if ratio_direction == :height
        if styles[:height]
          styles[:width] = styles[:height] * @ratio
        else
          styles.delete(:width)
        end
      elsif ratio_direction == :width
        if styles[:width]
          styles[:height] = styles[:width] * @ratio
        else
          styles.delete(:height)
        end
      end
    end

    super styles

    @image.style(height: @image.parent.height, width: @image.parent.width) if @image
    @app.gui.redraw
    @style
  end

  def initialize_widget(opts = {})
    @stack = stack top: 0, left: 0, width: '100%', height: '100%' do
      @image = image opts[:path]
      @selected_border = border black, linestyle: :dot
      @selected_border.hide
    end

    @path = opts[:path]
    @script = opts[:script]
    @name = opts[:name]

    # technically we should use these from opts instead of h/w (or should we?)
    # but instead I am just recalculating them on instantiation (dumb)
    @ratio, @ratio_direction = if opts[:ratio]
                                 [opts[:ratio], opts[:ratio_direction]]
                               else
                                 image_size_properties
                               end

    # if instantiating with a desired h/w, set those styles on the image first
    # because we use the image's h/w to set the overall h/w
    # BECAUSE the image proportion should be retained (by loading that first)
    # and keep its proportion and i don't feel like trying to override that right now
    # ALSO keep things from being too big!!
    if opts[:height] && opts[:width]
      @image.style height: opts[:height], width: opts[:width]
    elsif @image.width > parent.width
      new_dimensions = {}

      if @ratio_direction == :width
        new_dimensions[:width] = parent.width
        new_dimensions[:height] = parent.width * @ratio
      else
        new_dimensions[:height] = parent.height
        new_dimensions[:width] = parent.height * @ratio
      end

      @image.style new_dimensions
    elsif @image.height > parent.height
      new_dimensions = {}

      if @ratio_direction == :height
        new_dimensions[:height] = parent.height
        new_dimensions[:width] = parent.height * @ratio
      else
        new_dimensions[:width] = parent.width
        new_dimensions[:height] = parent.width * @ratio
      end

      @image.style new_dimensions
    end

    # set top/left/height/width on the outer "cool image" container
    style_opts = { width: @image.width, height: @image.height }
    style_opts[:left] = opts[:left] || parent.width / 2 - @image.width / 2
    style_opts[:top] = opts[:top] || parent.height / 2 - @image.height / 2

    style style_opts
  end

  def select
    @selected_border.show
  end

  def deselect
    @selected_border.hide
  end

  def opts
    {
      'type' => 'image',
      'top' => top,
      'left' => left,
      'width' => width,
      'height' => height,
      'ratio' => @ratio,
      'ratio_direction' => @ratio_direction,
      'name' => @name,
      'path' => @path,
      'script' => @script
    }
  end

  private

  def image_size_properties
    if @image.height > @image.width
      [@image.width.to_f / @image.height.to_f, :height]
    else
      [@image.height.to_f / @image.width.to_f, :width]
    end
  end
end
