class CoolFieldToo < CoolElement
  attr_accessor :name, :locked, :editable
  attr_reader :font_size

  def locked?
    @locked
  end

  def transparent?
    @transparent
  end

  def transparent= transparent
    @transparent = transparent
    @background.style hidden: @transparent
  end

  def text
    @words.text
  end

  def text= text
    @words.replace text
  end

  def remove_chars count = 1
    rng = 0...(0 - count)
    @words.text = @words.text[rng]
  end

  def add_text text
    @words.cursor = @words.text.length + text.length
    @words.text += text
  end

  def cursor= position
    @words.cursor = position
  end

  def font_size= font_size
    @font_size = font_size
    @words.style size: @font_size
  end

  def border_hidden= hide_border
    @hide_border = hide_border
    @normal_border.style hidden: @hide_border
  end

  def border_hidden?
    @hide_border
  end

  def focus do_focus
    if do_focus
      @words.cursor = -1

      # @cursor_animation = animate(2) do |frame|
      #   if (frame % 2).zero?
      #     @words.cursor = @words.text.length
      #   else
      #     @words.cursor = nil
      #   end
      # end
    else
      @cursor_animation.stop if @cursor_animation

      @words.cursor = nil
    end
  end

  def initialize_widget opts = {}
    style_opts = { width: (opts[:width] || 100), height: (opts[:height] || 25) }
    style_opts[:left] = opts[:left] || parent.width / 2 - style_opts[:width] / 2
    style_opts[:top] = opts[:top] || parent.height / 2 - style_opts[:height] / 2

    style style_opts

    @stack =stack width: '100%', height: '100%' do
      @background = background white
      @normal_border = border black
      @selected_border = border black, linestyle: :dot
      @selected_border.hide
      @words = para opts[:text] || '', margin: 5, top: 0, left: 0, width: '100%', height: '100%'
      @words.style size: opts[:font_size] if opts[:font_size]
    end

    @transparent = opts[:transparent] || false
    @background.hide if @transparent
    @hide_border = opts[:hide_border]
    @normal_border.style hidden: @hide_border
    @font_size = @words.style[:size]
    @script = opts[:script]
    @name = opts[:name]
  end

  def select
    @normal_border.hide
    @selected_border.show
  end

  def deselect
    @normal_border.show unless border_hidden?
    @selected_border.hide
  end

  def opts
    {
      'type' => 'field_too',
      'top' => top,
      'left' => left,
      'width' => width,
      'height' => height,
      'name' => name,
      'text' => text,
      'locked' => locked,
      'font_size' => font_size,
      'hide_border' => @hide_border,
      'transparent' => @transparent
    }
  end
end
